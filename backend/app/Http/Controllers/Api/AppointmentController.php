<?php

namespace App\Http\Controllers\Api;

use App\Models\Appointment;
use App\Models\AuditLog;
use App\Models\Patient;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class AppointmentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $appointments = Appointment::query()
            ->whereHas('patient', fn (Builder $query) => $query->where('branch_id', $request->user()->branch_id))
            ->with('patient:id,file_no,name,phone')
            ->when($request->filled('date'), fn (Builder $query) => $query->whereDate('appointment_date', $request->query('date')))
            ->when($request->filled('status'), fn (Builder $query) => $query->where('status', $request->query('status')))
            ->orderBy('appointment_date')
            ->orderBy('appointment_time')
            ->paginate(min(max((int) $request->query('per_page', 25), 1), 100));

        return response()->json($appointments);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'patient_id' => ['required', 'uuid', Rule::exists('patients', 'id')],
            'doctor' => ['nullable', 'string', 'max:200'],
            'appointment_date' => ['required', 'date'],
            'appointment_time' => ['required', 'date_format:H:i'],
            'status' => ['nullable', Rule::in(['confirmed', 'arrived', 'completed', 'cancelled', 'no_show'])],
            'notes' => ['nullable', 'string', 'max:5000'],
        ]);

        $patient = Patient::query()
            ->where('branch_id', $request->user()->branch_id)
            ->findOrFail($data['patient_id']);

        $appointment = $patient->appointments()->create([
            'doctor' => $data['doctor'] ?? null,
            'appointment_date' => $data['appointment_date'],
            'appointment_time' => $data['appointment_time'],
            'status' => $data['status'] ?? 'confirmed',
            'notes' => $data['notes'] ?? null,
        ]);

        AuditLog::create([
            'user_id' => $request->user()->id,
            'branch_id' => $request->user()->branch_id,
            'action' => 'appointment.created',
            'entity' => 'appointment',
            'entity_id' => $appointment->id,
            'details' => ['patient_id' => $patient->id, 'date' => $appointment->appointment_date->toDateString()],
            'created_at' => now(),
        ]);

        return response()->json(['data' => $appointment->load('patient:id,file_no,name,phone')], 201);
    }

    public function show(Request $request, string $appointment): JsonResponse
    {
        $record = Appointment::query()
            ->whereHas('patient', fn (Builder $query) => $query->where('branch_id', $request->user()->branch_id))
            ->with('patient:id,file_no,name,phone')
            ->findOrFail($appointment);

        return response()->json(['data' => $record]);
    }

    public function update(Request $request, string $appointment): JsonResponse
    {
        $record = Appointment::query()
            ->whereHas('patient', fn (Builder $query) => $query->where('branch_id', $request->user()->branch_id))
            ->findOrFail($appointment);

        $data = $request->validate([
            'doctor' => ['sometimes', 'nullable', 'string', 'max:200'],
            'appointment_date' => ['sometimes', 'required', 'date'],
            'appointment_time' => ['sometimes', 'required', 'date_format:H:i'],
            'status' => ['sometimes', 'required', Rule::in(['confirmed', 'arrived', 'completed', 'cancelled', 'no_show'])],
            'notes' => ['sometimes', 'nullable', 'string', 'max:5000'],
        ]);

        $record->fill($data)->save();

        AuditLog::create([
            'user_id' => $request->user()->id,
            'branch_id' => $request->user()->branch_id,
            'action' => 'appointment.updated',
            'entity' => 'appointment',
            'entity_id' => $record->id,
            'details' => ['fields' => array_keys($data)],
            'created_at' => now(),
        ]);

        return response()->json(['data' => $record->fresh()->load('patient:id,file_no,name,phone')]);
    }
}
