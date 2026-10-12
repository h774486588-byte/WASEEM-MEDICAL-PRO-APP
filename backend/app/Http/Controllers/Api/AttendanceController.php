<?php

namespace App\Http\Controllers\Api;

use App\Models\AttendanceRecord;
use App\Models\AuditLog;
use App\Models\MedicalStaff;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class AttendanceController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = AttendanceRecord::query()
            ->whereHas('staff', fn (Builder $staff) => $staff->where('branch_id', $request->user()->branch_id))
            ->with('staff:id,full_name,role')
            ->when($request->filled('date'), fn (Builder $q) => $q->whereDate('attendance_date', $request->query('date')))
            ->when($request->filled('staff_id'), fn (Builder $q) => $q->where('staff_id', $request->query('staff_id')))
            ->orderByDesc('attendance_date')
            ->orderBy('staff_id');

        return response()->json($query->paginate(min(max((int) $request->query('per_page', 50), 1), 100)));
    }

    public function store(Request $request, string $staff): JsonResponse
    {
        $data = $request->validate([
            'attendance_date' => ['nullable', 'date', 'before_or_equal:today'],
            'status' => ['required', Rule::in(['present', 'late', 'absent', 'leave'])],
            'check_in' => ['nullable', 'date_format:H:i'],
            'notes' => ['nullable', 'string', 'max:3000'],
        ]);

        $date = $data['attendance_date'] ?? today()->toDateString();
        $record = DB::transaction(function () use ($request, $staff, $data, $date): AttendanceRecord {
            $person = MedicalStaff::query()
                ->where('branch_id', $request->user()->branch_id)
                ->lockForUpdate()
                ->findOrFail($staff);

            $record = AttendanceRecord::query()
                ->where('staff_id', $person->id)
                ->whereDate('attendance_date', $date)
                ->first();

            $attributes = [
                'status' => $data['status'],
                'check_in' => in_array($data['status'], ['present', 'late'], true) ? ($data['check_in'] ?? now()->format('H:i')) : null,
                'notes' => $data['notes'] ?? null,
                'recorded_by' => $request->user()->id,
            ];

            if ($record) {
                $record->fill($attributes)->save();
            } else {
                $record = AttendanceRecord::create([
                    'staff_id' => $person->id,
                    'attendance_date' => $date,
                    ...$attributes,
                ]);
            }

            AuditLog::create([
                'user_id' => $request->user()->id,
                'branch_id' => $request->user()->branch_id,
                'action' => 'attendance.recorded',
                'entity' => 'attendance_record',
                'entity_id' => $record->id,
                'details' => ['staff_id' => $person->id, 'date' => $date, 'status' => $record->status],
                'created_at' => now(),
            ]);

            return $record;
        }, attempts: 3);

        return response()->json(['data' => $record->load('staff:id,full_name,role')], 201);
    }
}
