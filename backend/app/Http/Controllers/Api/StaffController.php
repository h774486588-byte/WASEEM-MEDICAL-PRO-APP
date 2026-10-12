<?php

namespace App\Http\Controllers\Api;

use App\Models\AuditLog;
use App\Models\MedicalStaff;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StaffController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = MedicalStaff::query()
            ->where('branch_id', $request->user()->branch_id)
            ->when($request->has('active'), fn (Builder $q) => $q->where('is_active', filter_var($request->query('active'), FILTER_VALIDATE_BOOLEAN)))
            ->when($request->filled('q'), function (Builder $q) use ($request): void {
                $term = trim((string) $request->query('q'));
                $q->where(function (Builder $search) use ($term): void {
                    $search->where('full_name', 'like', '%'.$term.'%')
                        ->orWhere('phone', 'like', '%'.$term.'%')
                        ->orWhere('specialty', 'like', '%'.$term.'%');
                });
            })
            ->orderBy('full_name');

        return response()->json($query->paginate(min(max((int) $request->query('per_page', 25), 1), 100)));
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'full_name' => ['required', 'string', 'max:200'],
            'role' => ['required', 'string', 'max:80'],
            'specialty' => ['nullable', 'string', 'max:150'],
            'phone' => ['nullable', 'string', 'max:40'],
            'email' => ['nullable', 'email', 'max:200'],
            'monthly_salary' => ['nullable', 'numeric', 'min:0', 'max:9999999999.99'],
        ]);

        $staff = MedicalStaff::create([
            ...$data,
            'branch_id' => $request->user()->branch_id,
            'monthly_salary' => $data['monthly_salary'] ?? 0,
            'is_active' => true,
        ]);

        $this->audit($request, 'staff.created', $staff, [
            'role' => $staff->role,
            'monthly_salary' => $staff->monthly_salary,
        ]);

        return response()->json(['data' => $staff], 201);
    }

    public function show(Request $request, string $staff): JsonResponse
    {
        $record = $this->branchQuery($request)->findOrFail($staff);

        return response()->json(['data' => $record]);
    }

    public function update(Request $request, string $staff): JsonResponse
    {
        $record = $this->branchQuery($request)->findOrFail($staff);
        $data = $request->validate([
            'full_name' => ['sometimes', 'required', 'string', 'max:200'],
            'role' => ['sometimes', 'required', 'string', 'max:80'],
            'specialty' => ['sometimes', 'nullable', 'string', 'max:150'],
            'phone' => ['sometimes', 'nullable', 'string', 'max:40'],
            'email' => ['sometimes', 'nullable', 'email', 'max:200'],
            'monthly_salary' => ['sometimes', 'required', 'numeric', 'min:0', 'max:9999999999.99'],
            'is_active' => ['sometimes', 'boolean'],
        ]);

        $record->fill($data)->save();
        $this->audit($request, 'staff.updated', $record, ['fields' => array_keys($data)]);

        return response()->json(['data' => $record->fresh()]);
    }

    public function destroy(Request $request, string $staff): JsonResponse
    {
        $record = $this->branchQuery($request)->findOrFail($staff);
        $record->is_active = false;
        $record->save();
        $this->audit($request, 'staff.archived', $record);

        return response()->json(['message' => 'تم إيقاف ملف الموظف مع إبقاء سجل الحضور والرواتب.']);
    }

    private function branchQuery(Request $request): Builder
    {
        return MedicalStaff::query()->where('branch_id', $request->user()->branch_id);
    }

    private function audit(Request $request, string $action, MedicalStaff $staff, array $details = []): void
    {
        AuditLog::create([
            'user_id' => $request->user()->id,
            'branch_id' => $request->user()->branch_id,
            'action' => $action,
            'entity' => 'medical_staff',
            'entity_id' => $staff->id,
            'details' => $details,
            'created_at' => now(),
        ]);
    }
}
