<?php

namespace App\Http\Controllers\Api;

use App\Models\AuditLog;
use App\Models\MedicalPackage;
use App\Models\TherapySession;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class SessionController extends Controller
{
    public function store(Request $request, string $package): JsonResponse
    {
        $data = $request->validate([
            'session_date' => ['nullable', 'date'],
            'session_time' => ['nullable', 'date_format:H:i'],
            'therapist' => ['nullable', 'string', 'max:200'],
            'status' => ['nullable', 'in:attended,missed,cancelled'],
            'notes' => ['nullable', 'string', 'max:5000'],
        ]);

        $result = DB::transaction(function () use ($request, $package, $data): array {
            $record = MedicalPackage::query()
                ->whereHas('patient', fn (Builder $patient) => $patient->where('branch_id', $request->user()->branch_id))
                ->with('patient')
                ->lockForUpdate()
                ->findOrFail($package);

            $status = $data['status'] ?? 'attended';
            if ($status === 'attended' && $record->remaining_sessions < 1) {
                throw ValidationException::withMessages([
                    'package' => 'انتهت جلسات هذه الباقة، ولا يمكن تسجيل جلسة إضافية.',
                ]);
            }

            $session = TherapySession::create([
                'patient_id' => $record->patient_id,
                'package_id' => $record->id,
                'therapist' => $data['therapist'] ?? null,
                'session_date' => $data['session_date'] ?? today()->toDateString(),
                'session_time' => $data['session_time'] ?? now()->format('H:i:s'),
                'status' => $status,
                'notes' => $data['notes'] ?? null,
                'created_by' => $request->user()->id,
            ]);

            if ($status === 'attended') {
                $record->remaining_sessions = max(0, $record->remaining_sessions - 1);
                $record->save();

                if ($record->remaining_sessions === 2 || $record->remaining_sessions === 0) {
                    $isFinished = $record->remaining_sessions === 0;
                    DB::table('notifications')->insert([
                        'id' => (string) \Illuminate\Support\Str::uuid(),
                        'patient_id' => $record->patient_id,
                        'channel' => 'system',
                        'event_type' => $isFinished ? 'package_finished' : 'package_low',
                        'recipient' => $record->patient->phone,
                        'message' => $isFinished
                            ? 'انتهت جلسات الباقة: '.$record->name
                            : 'تبقت جلستان فقط في الباقة: '.$record->name,
                        'status' => 'queued',
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }

            AuditLog::create([
                'user_id' => $request->user()->id,
                'branch_id' => $request->user()->branch_id,
                'action' => 'session.recorded',
                'entity' => 'session',
                'entity_id' => $session->id,
                'details' => [
                    'patient_id' => $record->patient_id,
                    'package_id' => $record->id,
                    'status' => $status,
                    'remaining_sessions' => $record->remaining_sessions,
                ],
                'created_at' => now(),
            ]);

            return ['session' => $session, 'package' => $record->fresh()];
        }, attempts: 3);

        return response()->json([
            'data' => $result['session'],
            'package' => $result['package'],
        ], 201);
    }
}
