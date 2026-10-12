<?php

namespace Tests\Feature;

use App\Models\Branch;
use App\Models\Invoice;
use App\Models\MedicalPackage;
use App\Models\Patient;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ClinicApiTest extends TestCase
{
    use RefreshDatabase;

    private function branch(string $name = 'الفرع الرئيسي'): Branch
    {
        return Branch::create(['name' => $name, 'next_patient_number' => 1001]);
    }

    private function user(Branch $branch, string $role = 'owner', string $username = 'clinicowner'): User
    {
        return User::create([
            'branch_id' => $branch->id,
            'name' => 'مدير الاختبار',
            'username' => $username,
            'password_hash' => Hash::make('Test-Passphrase-2026!'),
            'role' => $role,
            'is_active' => true,
        ]);
    }

    private function patient(Branch $branch, User $user, string $fileNo = 'P-1001'): Patient
    {
        return Patient::create([
            'branch_id' => $branch->id,
            'created_by' => $user->id,
            'file_no' => $fileNo,
            'name' => 'مريض تجريبي',
            'phone' => '777000000',
            'gender' => 'ذكر',
        ]);
    }

    public function test_login_returns_a_bearer_token_for_an_active_user(): void
    {
        $branch = $this->branch();
        $user = $this->user($branch);

        $response = $this->postJson('/api/auth/login', [
            'username' => $user->username,
            'password' => 'Test-Passphrase-2026!',
            'device_name' => 'CI test',
        ]);

        $response->assertOk()
            ->assertJsonPath('user.id', $user->id)
            ->assertJsonPath('user.role', 'owner')
            ->assertJsonStructure(['access_token', 'token_type', 'expires_at', 'user']);

        $token = $response->json('access_token');
        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/auth/me')
            ->assertOk()
            ->assertJsonPath('user.username', $user->username);
    }

    public function test_login_does_not_accept_the_wrong_password(): void
    {
        $branch = $this->branch();
        $user = $this->user($branch);

        $this->postJson('/api/auth/login', [
            'username' => $user->username,
            'password' => 'wrong-password',
        ])->assertUnauthorized();
    }

    public function test_patient_numbers_are_generated_and_files_are_scoped_to_the_users_branch(): void
    {
        $branchA = $this->branch('فرع أ');
        $branchB = $this->branch('فرع ب');
        $userA = $this->user($branchA, 'owner', 'owner_a');
        $userB = $this->user($branchB, 'owner', 'owner_b');
        $patientB = $this->patient($branchB, $userB, 'P-1001');

        Sanctum::actingAs($userA);
        $created = $this->postJson('/api/patients', [
            'name' => 'وسام الاختبار',
            'phone' => '777111222',
            'gender' => 'ذكر',
        ])->assertCreated()->assertJsonPath('data.file_no', 'P-1001');

        $this->assertDatabaseHas('patients', [
            'id' => $created->json('data.id'),
            'branch_id' => $branchA->id,
            'created_by' => $userA->id,
        ]);

        $this->getJson('/api/patients')
            ->assertOk()
            ->assertJsonMissing(['id' => $patientB->id]);
    }

    public function test_invoice_payments_update_the_balance_and_reject_overpayment(): void
    {
        $branch = $this->branch();
        $user = $this->user($branch, 'accountant', 'accountant1');
        $patient = $this->patient($branch, $user);

        Sanctum::actingAs($user);
        $invoiceResponse = $this->postJson('/api/invoices', [
            'patient_id' => $patient->id,
            'total' => 100,
            'initial_payment' => 0,
        ])->assertCreated();

        $invoiceId = $invoiceResponse->json('data.id');

        $this->postJson('/api/invoices/'.$invoiceId.'/payments', [
            'amount' => 30,
            'method' => 'cash',
        ])->assertOk()
            ->assertJsonPath('data.paid', '30.00')
            ->assertJsonPath('data.status', 'partial');

        $this->postJson('/api/invoices/'.$invoiceId.'/payments', [
            'amount' => 70,
            'method' => 'bank_transfer',
        ])->assertOk()
            ->assertJsonPath('data.paid', '100.00')
            ->assertJsonPath('data.status', 'paid');

        $this->postJson('/api/invoices/'.$invoiceId.'/payments', [
            'amount' => 1,
            'method' => 'cash',
        ])->assertUnprocessable();

        $this->assertDatabaseCount('payments', 2);
        $this->assertDatabaseHas('invoices', ['id' => $invoiceId, 'paid' => 100, 'status' => 'paid']);
    }

    public function test_attended_session_consumes_one_session_and_cannot_go_below_zero(): void
    {
        $branch = $this->branch();
        $user = $this->user($branch, 'therapist', 'therapist1');
        $patient = $this->patient($branch, $user);
        $package = MedicalPackage::create([
            'patient_id' => $patient->id,
            'name' => 'باقة اختبار',
            'price' => 100,
            'paid' => 100,
            'sessions_count' => 1,
            'remaining_sessions' => 1,
        ]);

        Sanctum::actingAs($user);
        $this->postJson('/api/packages/'.$package->id.'/sessions', [
            'therapist' => 'أخصائي اختبار',
            'status' => 'attended',
        ])->assertCreated()->assertJsonPath('package.remaining_sessions', 0);

        $this->postJson('/api/packages/'.$package->id.'/sessions', [
            'therapist' => 'أخصائي اختبار',
            'status' => 'attended',
        ])->assertUnprocessable();

        $this->assertDatabaseHas('packages', ['id' => $package->id, 'remaining_sessions' => 0]);
        $this->assertDatabaseCount('sessions', 1);
    }

    public function test_reception_cannot_record_payments(): void
    {
        $branch = $this->branch();
        $user = $this->user($branch, 'reception', 'reception1');
        $patient = $this->patient($branch, $user);
        $invoice = Invoice::create([
            'patient_id' => $patient->id,
            'invoice_no' => 'INV-CI-1001',
            'total' => 100,
            'paid' => 0,
            'status' => 'unpaid',
        ]);

        Sanctum::actingAs($user);
        $this->postJson('/api/invoices/'.$invoice->id.'/payments', [
            'amount' => 10,
            'method' => 'cash',
        ])->assertForbidden();
    }
}
