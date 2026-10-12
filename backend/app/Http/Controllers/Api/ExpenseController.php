<?php

namespace App\Http\Controllers\Api;

use App\Models\AuditLog;
use App\Models\Expense;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ExpenseController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Expense::query()
            ->where('branch_id', $request->user()->branch_id)
            ->when($request->filled('from'), fn (Builder $q) => $q->whereDate('expense_date', '>=', $request->query('from')))
            ->when($request->filled('to'), fn (Builder $q) => $q->whereDate('expense_date', '<=', $request->query('to')))
            ->when($request->filled('category'), fn (Builder $q) => $q->where('category', $request->query('category')))
            ->orderByDesc('expense_date')
            ->orderByDesc('created_at');

        return response()->json($query->paginate(min(max((int) $request->query('per_page', 25), 1), 100)));
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'category' => ['required', 'string', 'max:100'],
            'description' => ['required', 'string', 'max:5000'],
            'amount' => ['required', 'numeric', 'gt:0', 'max:9999999999.99'],
            'payment_method' => ['required', Rule::in(['cash', 'card', 'bank_transfer', 'wallet'])],
            'expense_date' => ['required', 'date'],
        ]);

        $expense = Expense::create([
            ...$data,
            'branch_id' => $request->user()->branch_id,
            'created_by' => $request->user()->id,
        ]);

        $this->audit($request, 'expense.created', $expense, [
            'amount' => $expense->amount,
            'category' => $expense->category,
        ]);

        return response()->json(['data' => $expense], 201);
    }

    public function show(Request $request, string $expense): JsonResponse
    {
        return response()->json([
            'data' => Expense::query()
                ->where('branch_id', $request->user()->branch_id)
                ->findOrFail($expense),
        ]);
    }

    public function update(Request $request, string $expense): JsonResponse
    {
        $record = Expense::query()
            ->where('branch_id', $request->user()->branch_id)
            ->findOrFail($expense);

        $data = $request->validate([
            'category' => ['sometimes', 'required', 'string', 'max:100'],
            'description' => ['sometimes', 'required', 'string', 'max:5000'],
            'amount' => ['sometimes', 'required', 'numeric', 'gt:0', 'max:9999999999.99'],
            'payment_method' => ['sometimes', 'required', Rule::in(['cash', 'card', 'bank_transfer', 'wallet'])],
            'expense_date' => ['sometimes', 'required', 'date'],
        ]);

        $record->fill($data)->save();
        $this->audit($request, 'expense.updated', $record, ['fields' => array_keys($data)]);

        return response()->json(['data' => $record->fresh()]);
    }

    public function destroy(Request $request, string $expense): JsonResponse
    {
        $record = Expense::query()
            ->where('branch_id', $request->user()->branch_id)
            ->findOrFail($expense);

        $this->audit($request, 'expense.deleted', $record, [
            'amount' => $record->amount,
            'category' => $record->category,
        ]);
        $record->delete();

        return response()->json(['message' => 'تم حذف المصروف وتسجيل العملية في سجل التدقيق.']);
    }

    private function audit(Request $request, string $action, Expense $expense, array $details = []): void
    {
        AuditLog::create([
            'user_id' => $request->user()->id,
            'branch_id' => $request->user()->branch_id,
            'action' => $action,
            'entity' => 'expense',
            'entity_id' => $expense->id,
            'details' => $details,
            'created_at' => now(),
        ]);
    }
}
