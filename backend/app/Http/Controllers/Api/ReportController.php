<?php

namespace App\Http\Controllers\Api;

use App\Models\Appointment;
use App\Models\Expense;
use App\Models\Invoice;
use App\Models\MedicalPackage;
use App\Models\MedicalStaff;
use App\Models\PayrollEntry;
use App\Models\Patient;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $branchId = $request->user()->branch_id;
        $patients = Patient::query()->where('branch_id', $branchId);
        $appointments = Appointment::query()->whereHas(
            'patient',
            fn (Builder $patient) => $patient->where('branch_id', $branchId),
        );
        $packages = MedicalPackage::query()->whereHas(
            'patient',
            fn (Builder $patient) => $patient->where('branch_id', $branchId),
        );
        $invoices = Invoice::query()->whereHas(
            'patient',
            fn (Builder $patient) => $patient->where('branch_id', $branchId),
        );

        $invoiceTotals = (clone $invoices)->selectRaw('COALESCE(SUM(total), 0) AS total, COALESCE(SUM(paid), 0) AS paid')->first();
        $expenseTotal = Expense::query()->where('branch_id', $branchId)->sum('amount');
        $staffCount = MedicalStaff::query()->where('branch_id', $branchId)->where('is_active', true)->count();
        $month = today()->format('Y-m');
        $monthPayroll = PayrollEntry::query()
            ->whereHas('staff', fn (Builder $staff) => $staff->where('branch_id', $branchId))
            ->where('month', $month);
        $salaryPaid = (clone $monthPayroll)->where('entry_type', 'salary_payment')->sum('amount');
        $salaryDeductions = (clone $monthPayroll)->where('entry_type', 'deduction')->sum('amount');

        return response()->json([
            'data' => [
                'patients' => (clone $patients)->count(),
                'appointments_today' => (clone $appointments)->whereDate('appointment_date', today())->count(),
                'appointments_upcoming' => (clone $appointments)->whereDate('appointment_date', '>=', today())
                    ->whereNotIn('status', ['cancelled', 'no_show'])->count(),
                'packages' => (clone $packages)->count(),
                'sessions_used' => (clone $packages)->sum(DB::raw('sessions_count - remaining_sessions')),
                'sessions_remaining' => (clone $packages)->sum('remaining_sessions'),
                'invoice_total' => round((float) ($invoiceTotals->total ?? 0), 2),
                'invoice_paid' => round((float) ($invoiceTotals->paid ?? 0), 2),
                'invoice_outstanding' => round((float) ($invoiceTotals->total ?? 0) - (float) ($invoiceTotals->paid ?? 0), 2),
                'expenses' => round((float) $expenseTotal, 2),
                'active_staff' => $staffCount,
                'salary_paid_this_month' => round((float) $salaryPaid, 2),
                'salary_deductions_this_month' => round((float) $salaryDeductions, 2),
                'period' => ['date' => today()->toDateString(), 'month' => $month, 'timezone' => config('app.timezone')],
            ],
        ]);
    }
}
