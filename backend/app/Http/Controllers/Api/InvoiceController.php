<?php

namespace App\Http\Controllers\Api;

use App\Models\AuditLog;
use App\Models\Invoice;
use App\Models\Patient;
use App\Models\Payment;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class InvoiceController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Invoice::query()
            ->whereHas('patient', fn (Builder $patient) => $patient->where('branch_id', $request->user()->branch_id))
            ->with(['patient:id,file_no,name,phone', 'payments'])
            ->orderByDesc('issued_at');

        if ($request->filled('patient_id')) {
            $query->where('patient_id', $request->query('patient_id'));
        }

        return response()->json($query->paginate(min(max((int) $request->query('per_page', 25), 1), 100)));
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'patient_id' => ['required', 'uuid', Rule::exists('patients', 'id')],
            'total' => ['required', 'numeric', 'gt:0', 'max:9999999999.99'],
            'initial_payment' => ['nullable', 'numeric', 'min:0', 'lte:total'],
            'payment_method' => ['nullable', Rule::in(['cash', 'card', 'bank_transfer', 'wallet'])],
            'notes' => ['nullable', 'string', 'max:5000'],
        ]);

        $patient = Patient::query()
            ->where('branch_id', $request->user()->branch_id)
            ->findOrFail($data['patient_id']);

        $invoice = DB::transaction(function () use ($data, $patient, $request): Invoice {
            $total = round((float) $data['total'], 2);
            $initial = round((float) ($data['initial_payment'] ?? 0), 2);
            $status = $initial >= $total ? 'paid' : ($initial > 0 ? 'partial' : 'unpaid');

            $invoice = Invoice::create([
                'patient_id' => $patient->id,
                'invoice_no' => 'INV-'.now()->format('YmdHis').'-'.Str::upper(Str::random(4)),
                'total' => $total,
                'paid' => $initial,
                'status' => $status,
                'issued_at' => now(),
            ]);

            if ($initial > 0) {
                $invoice->payments()->create([
                    'amount' => $initial,
                    'method' => $data['payment_method'] ?? 'cash',
                    'paid_at' => now(),
                    'notes' => $data['notes'] ?? 'الدفعة المسجلة عند إنشاء الفاتورة',
                ]);
            }

            AuditLog::create([
                'user_id' => $request->user()->id,
                'branch_id' => $request->user()->branch_id,
                'action' => 'invoice.created',
                'entity' => 'invoice',
                'entity_id' => $invoice->id,
                'details' => ['patient_id' => $patient->id, 'total' => $total, 'initial_payment' => $initial],
                'created_at' => now(),
            ]);

            return $invoice;
        });

        return response()->json(['data' => $invoice->load(['patient:id,file_no,name,phone', 'payments'])], 201);
    }

    public function show(Request $request, string $invoice): JsonResponse
    {
        $record = $this->branchQuery($request)
            ->with(['patient:id,file_no,name,phone', 'payments'])
            ->findOrFail($invoice);

        return response()->json(['data' => $record]);
    }

    public function recordPayment(Request $request, string $invoice): JsonResponse
    {
        $data = $request->validate([
            'amount' => ['required', 'numeric', 'gt:0', 'max:9999999999.99'],
            'method' => ['required', Rule::in(['cash', 'card', 'bank_transfer', 'wallet'])],
            'notes' => ['nullable', 'string', 'max:5000'],
        ]);

        $updated = DB::transaction(function () use ($request, $invoice, $data): Invoice {
            $record = $this->branchQuery($request)->lockForUpdate()->findOrFail($invoice);
            $amount = round((float) $data['amount'], 2);
            $remaining = round((float) $record->total - (float) $record->paid, 2);

            if ($amount > $remaining) {
                throw ValidationException::withMessages([
                    'amount' => 'مبلغ الدفعة أكبر من المتبقي في الفاتورة.',
                ]);
            }

            $record->payments()->create([
                'amount' => $amount,
                'method' => $data['method'],
                'paid_at' => now(),
                'notes' => $data['notes'] ?? null,
            ]);

            $record->paid = round((float) $record->paid + $amount, 2);
            $record->status = $record->paid >= $record->total
                ? 'paid'
                : ($record->paid > 0 ? 'partial' : 'unpaid');
            $record->save();

            AuditLog::create([
                'user_id' => $request->user()->id,
                'branch_id' => $request->user()->branch_id,
                'action' => 'invoice.payment_recorded',
                'entity' => 'invoice',
                'entity_id' => $record->id,
                'details' => ['amount' => $amount, 'method' => $data['method'], 'remaining' => $record->remaining],
                'created_at' => now(),
            ]);

            return $record;
        }, attempts: 3);

        return response()->json([
            'data' => $updated->fresh()->load(['patient:id,file_no,name,phone', 'payments']),
        ]);
    }

    private function branchQuery(Request $request): Builder
    {
        return Invoice::query()->whereHas(
            'patient',
            fn (Builder $patient) => $patient->where('branch_id', $request->user()->branch_id),
        );
    }
}
