<?php

namespace App\Http\Controllers\Api;

use App\Models\AuditLog;
use App\Models\MedicalPackage;
use App\Models\Patient;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PackageController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = MedicalPackage::query()
            ->whereHas('patient', fn (Builder $patient) => $patient->where('branch_id', $request->user()->branch_id))
            ->with('patient:id,file_no,name,phone')
            ->orderByDesc('created_at');

        if ($request->filled('patient_id')) {
            $query->where('patient_id', $request->query('patient_id'));
        }

        return response()->json($query->paginate(min(max((int) $request->query('per_page', 25), 1), 100)));
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'patient_id' => ['required', 'uuid', Rule::exists('patients', 'id')],
            'name' => ['required', 'string', 'max:200'],
            'price' => ['required', 'numeric', 'min:0', 'max:9999999999.99'],
            'paid' => ['nullable', 'numeric', 'min:0', 'lte:price'],
            'sessions_count' => ['required', 'integer', 'min:1', 'max:10000'],
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date', 'after_or_equal:start_date'],
        ]);

        $patient = Patient::query()
            ->where('branch_id', $request->user()->branch_id)
            ->findOrFail($data['patient_id']);

        $package = $patient->packages()->create([
            'name' => $data['name'],
            'price' => $data['price'],
            'paid' => $data['paid'] ?? 0,
            'sessions_count' => $data['sessions_count'],
            'remaining_sessions' => $data['sessions_count'],
            'start_date' => $data['start_date'] ?? null,
            'end_date' => $data['end_date'] ?? null,
        ]);

        AuditLog::create([
            'user_id' => $request->user()->id,
            'branch_id' => $request->user()->branch_id,
            'action' => 'package.created',
            'entity' => 'package',
            'entity_id' => $package->id,
            'details' => ['patient_id' => $patient->id, 'sessions_count' => $package->sessions_count],
            'created_at' => now(),
        ]);

        return response()->json(['data' => $package->load('patient:id,file_no,name,phone')], 201);
    }

    public function show(Request $request, string $package): JsonResponse
    {
        $record = MedicalPackage::query()
            ->whereHas('patient', fn (Builder $patient) => $patient->where('branch_id', $request->user()->branch_id))
            ->with(['patient:id,file_no,name,phone', 'sessions'])
            ->findOrFail($package);

        return response()->json(['data' => $record]);
    }
}
