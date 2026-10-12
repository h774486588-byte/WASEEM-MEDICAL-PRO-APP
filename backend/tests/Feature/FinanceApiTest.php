<?php

namespace Tests\Feature;

use App\Models\AttendanceRecord;
use App\Models\Branch;
use App\Models\MedicalStaff;
use App\Models\PayrollEntry;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FinanceApiTest extends TestCase
{
    use RefreshDatabase;

    private function branch(): Branch
    {
        return Branch::create([
            'name' => 'فرع مالي للاختبار',
            'next_patient_number' => 1001,
        ]);
    }

    private function user(Branch $branch, string $role, string $username): User
    {
        return User::create([
            'branch_id' => $branch->id,
            'name' => 'مستخدم اختبار',
            'username' => $username,
            'password_hash' => Hash::make('Test-Passphrase-2026!'),
            'role' => $role,
            'is_active' => true,
        ]);
    }

    private function staff(Branch $branch, float $salary = 1000): MedicalStaff
    {
        return MedicalStaff::create([
            'branch_id' => $branch->id,
            'full_name' => 'موظف اختباري',
            'role' => 'therapist',
            'specialty' => 'علاج طبيعي',
            'monthly_salary' => $salary,
            'is_active' => true,
        ]);
    }

    public function test_accountant_can_create_expense_and_expenses_are_scoped_to_branch(): void
    {
        $branchA = $this->branch();
        $branchB = Branch::create(['name' => 'فرع آخر', 'next_patient_number' => 1001]);
        $accountant = $this->user($branchA, 'accountant', 'accountant_finance');
        $otherBranchAccountant = $this->user($branchB, 'accountant', 'accountant_other');

        Sanctum::actingAs($accountant);
        $created = $this->postJson('/api/expenses', [
            'category' => 'maintenance',
            'description' => 'صيانة جهاز',
            'amount' => 125.50,
            'payment_method' => 'cash',
            'expense_date' => today()->toDateString(),
        ])->assertCreated();

        $expenseId = $created->json('data.id');
        $this->assertDatabaseHas('expenses', [
            'id' => $expenseId,
            'branch_id' => $branchA->id,
            'created_by' => $accountant->id,
            'amount' => 125.50,
        ]);

        $this->getJson('/api/expenses')->assertOk()->assertJsonPath('data.0.id', $expenseId);

        Sanctum::actingAs($otherBranchAccountant);
        $this->getJson('/api/expenses')->assertOk()->assertJsonMissing(['id' => $expenseId]);
    }

    public function test_owner_can_create_and_update_staff_salary(): void
    {
        $branch = $this->branch();
        $owner = $this->user($branch, 'owner', 'owner_staff');

        Sanctum::actingAs($owner);
        $created = $this->postJson('/api/staff', [
            'full_name' => 'أخصائي جديد',
            'role' => 'therapist',
            'specialty' => 'علاج طبيعي',
            'monthly_salary' => 800,
        ])->assertCreated()->assertJsonPath('data.full_name', 'أخصائي جديد');

        $staffId = $created->json('data.id');

        $this->patchJson('/api/staff/'.$staffId, [
            'monthly_salary' => 950,
            'phone' => '777111222',
        ])->assertOk()->assertJsonPath('data.monthly_salary', '950.00');

        $this->assertDatabaseHas('medical_staff', [
            'id' => $staffId,
            'branch_id' => $branch->id,
            'monthly_salary' => 950,
        ]);
    }

    public function test_attendance_updates_existing_daily_record_instead_of_duplicating_it(): void
    {
        $branch = $this->branch();
        $reception = $this->user($branch, 'reception', 'reception_attendance');
        $staff = $this->staff($branch);
        $date = today()->toDateString();

        Sanctum::actingAs($reception);
        $first = $this->postJson('/api/staff/'.$staff->id.'/attendance', [
            'attendance_date' => $date,
            'status' => 'present',
            'check_in' => '08:00',
        ])->assertCreated();

        $recordId = $first->json('data.id');

        $this->postJson('/api/staff/'.$staff->id.'/attendance', [
            'attendance_date' => $date,
            'status' => 'late',
            'check_in' => '08:30',
            'notes' => 'ازدحام الطريق',
        ])->assertCreated()->assertJsonPath('data.status', 'late');

        $this->assertDatabaseCount('attendance_records', 1);
        $this->assertDatabaseHas('attendance_records', [
            'id' => $recordId,
            'staff_id' => $staff->id,
            'status' => 'late',
            'check_in' => '08:30:00',
        ]);
    }

    public function test_payroll_payments_and_deductions_cannot_exceed_monthly_salary(): void
    {
        $branch = $this->branch();
        $accountant = $this->user($branch, 'accountant', 'accountant_payroll');
        $staff = $this->staff($branch, 1000);
        $month = today()->format('Y-m');

        Sanctum::actingAs($accountant);
        $this->postJson('/api/staff/'.$staff->id.'/payroll', [
            'entry_type' => 'deduction',
            'month' => $month,
            'amount' => 100,
            'method' => 'cash',
            'notes' => 'خصم تجريبي',
        ])->assertCreated();

        $this->postJson('/api/staff/'.$staff->id.'/payroll', [
            'entry_type' => 'salary_payment',
            'month' => $month,
            'amount' => 900,
            'method' => 'bank_transfer',
        ])->assertCreated();

        $this->postJson('/api/staff/'.$staff->id.'/payroll', [
            'entry_type' => 'salary_payment',
            'month' => $month,
            'amount' => 1,
            'method' => 'cash',
        ])->assertUnprocessable();

        $this->assertDatabaseCount('payroll_entries', 2);
        $this->assertDatabaseHas('payroll_entries', [
            'staff_id' => $staff->id,
            'entry_type' => 'deduction',
            'month' => $month,
            'amount' => 100,
        ]);
    }
}
