<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Branch;
use App\Models\Patient;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class PatientController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $patients = $this->branchQuery(Patient::query(), $request)
            ->when($request->filled('q'), function (Builder $query) use ($request): void {
                $term = trim((string) $request->query('q'));
                $query->where(function (Builder $search) use ($term): void {
                    $search->where('name', 'like', '%'.$term.'%')
                        ->orWhere('phone', 'like', '%'.$term.'%')
                        ->orWhere('file_no', 'like', '%'.$term.'%');
                });
            })
            ->orderByDesc('created_at')
            ->paginate(min(max((int) $request->query('per_page', 25), 1), 100));

        return response()->json($patients);
    }

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        if (! $user->branch_id) {
            throw ValidationException::withMessages([
                'branch_id' => 'اربط حساب المستخدم بفرع قبل تسجيل المرضى.',
            ]);
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:200'],
            'phone' => ['required', 'string', 'max:40'],
            'national_id' => ['nullable', 'string', 'max:80'],
            'birth_date' => ['nullable', 'date', 'before_or_equal:today'],
            'gender' => ['nullable', Rule::in(['ذكر', 'أنثى', 'غير محدد'])],
            'department' => ['nullable', 'string', 'max:150'],
            'service' => ['nullable', 'string', 'max:200'],
            'doctor' => ['nullable', 'string', 'max:200'],
            'alternate_phone' => ['nullable', 'string', 'max:40'],
            'address' => ['nullable', 'string', 'max:2000'],
            'notes' => ['nullable', 'string', 'max:10000'],
        ]);

        $patient = DB::transaction(function () use ($data, $user): Patient {
            $branch = Branch::query()->whereKey($user->branch_id)->lockForUpdate()->firstOrFail();
            $sequence = $branch->next_patient_number;
            $branch->next_patient_number = $sequence + 1;
            $branch->save();

            return Patient::create([
                ...$data,
                'branch_id' => $branch->id,
                'file_no' => 'P-'.$sequence,
                'created_by' => $user->id,
            ]);
        });

        $this->audit($request, 'patient.created', $patient, ['file_no' => $patient->file_no]);

        return response()->json(['data' => $patient], 201);
    }

    public function show(Request $request, string $patient): JsonResponse
    {
        return response()->json([
            'data' => $this->branchQuery(Patient::query(), $request)->findOrFail($patient),
        ]);
    }

    public function update(Request $request, string $patient): JsonResponse
    {
        $record = $this->branchQuery(Patient::query(), $request)->findOrFail($patient);
        $data = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:200'],
            'phone' => ['sometimes', 'required', 'string', 'max:40'],
            'national_id' => ['sometimes', 'nullable', 'string', 'max:80'],
            'birth_date' => ['sometimes', 'nullable', 'date', 'before_or_equal:today'],
            'gender' => ['sometimes', 'nullable', Rule::in(['ذكر', 'أنثى', 'غير محدد'])],
            'department' => ['sometimes', 'nullable', 'string', 'max:150'],
            'service' => ['sometimes', 'nullable', 'string', 'max:200'],
            'doctor' => ['sometimes', 'nullable', 'string', 'max:200'],
            'alternate_phone' => ['sometimes', 'nullable', 'string', 'max:40'],
            'address' => ['sometimes', 'nullable', 'string', 'max:2000'],
            'notes' => ['sometimes', 'nullable', 'string', 'max:10000'],
        ]);

        $record->fill($data)->save();
        $this->audit($request, 'patient.updated', $record, ['fields' => array_keys($data)]);

        return response()->json(['data' => $record->fresh()]);
    }

    public function destroy(Request $request, string $patient): JsonResponse
    {
        $record = $this->branchQuery(Patient::query(), $request)->findOrFail($patient);
        $record->delete();
        $this->audit($request, 'patient.archived', $record);

        return response()->json(['message' => 'تم أرشفة ملف المريض.']);
    }

    private function branchQuery(Builder $query, Request $request): Builder
    {
        return $query->where('branch_id', $request->user()->branch_id);
    }

    private function audit(Request $request, string $action, Patient $patient, array $details = []): void
    {
        AuditLog::create([
            'user_id' => $request->user()->id,
            'branch_id' => $request->user()->branch_id,
            'action' => $action,
            'entity' => 'patient',
            'entity_id' => $patient->id,
            'details' => $details,
            'created_at' => now(),
        ]);
    }
}
