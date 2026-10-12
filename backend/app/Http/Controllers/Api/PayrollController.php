<?php

namespace App\Http\Controllers\Api;

use App\Models\AuditLog;
use App\Models\MedicalStaff;
use App\Models\PayrollEntry;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class PayrollController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = PayrollEntry::query()
            ->whereHas('staff', fn (Builder $staff) => $staff->where('branch_id', $request->user()->branch_id))
            ->with('staff:id,full_name,role,monthly_salary')
            ->when($request->filled('month'), fn (Builder $q) => $q->where('month', $request->query('month')))
            ->when($request->filled('staff_id'), fn (Builder $q) => $q->where('staff_id', $request->query('staff_id')))
            ->orderByDesc('paid_at');

        return response()->json($query->paginate(min(max((int) $request->query('per_page', 50), 1), 100)));
    }

    public function store(Request $request, string $staff): JsonResponse
    {
        $data = $request->validate([
            'entry_type' => ['required', Rule::in(['salary_payment', 'deduction'])],
            'month' => ['required', 'date_format:Y-m'],
            'amount' => ['required', 'numeric', 'gt:0', 'max:9999999999.99'],
            'method' => ['required', Rule::in(['cash', 'card', 'bank_transfer', 'wallet'])],
            'paid_at' => ['nullable', 'date'],
            'notes' => ['nullable', 'string', 'max:3000'],
        ]);

        $entry = DB::transaction(function () use ($request, $staff, $data): PayrollEntry {
            $person = MedicalStaff::query()
                ->where('branch_id', $request->user()->branch_id)
                ->where('is_active', true)
                ->lockForUpdate()
                ->findOrFail($staff);

            $alreadyAllocated = (float) PayrollEntry::query()
                ->where('staff_id', $person->id)
                ->where('month', $data['month'])
                ->whereIn('entry_type', ['salary_payment', 'deduction'])
                ->sum('amount');

            $available = max(0, round((float) $person->monthly_salary - $alreadyAllocated, 2));
            $amount = round((float) $data['amount'], 2);

            if ($person->monthly_salary <= 0 || $amount > $available) {
                throw ValidationException::withMessages([
                    'amount' => 'المبلغ يتجاوز الرصيد المتاح من راتب هذا الشهر، أو أن الراتب الأساسي لم يُحدد.',
                ]);
            }

            $entry = PayrollEntry::create([
                'staff_id' => $person->id,
                'entry_type' => $data['entry_type'],
                'month' => $data['month'],
                'amount' => $amount,
                'method' => $data['method'],
                'paid_at' => $data['paid_at'] ?? now(),
                'notes' => $data['notes'] ?? null,
                'created_by' => $request->user()->id,
            ]);

            AuditLog::create([
                'user_id' => $request->user()->id,
                'branch_id' => $request->user()->branch_id,
                'action' => 'payroll.entry_recorded',
                'entity' => 'payroll_entry',
                'entity_id' => $entry->id,
                'details' => [
                    'staff_id' => $person->id,
                    'entry_type' => $entry->entry_type,
                    'month' => $entry->month,
                    'amount' => $entry->amount,
                ],
                'created_at' => now(),
            ]);

            return $entry;
        }, attempts: 3);

        return response()->json(['data' => $entry->load('staff:id,full_name,role,monthly_salary')], 201);
    }
}
