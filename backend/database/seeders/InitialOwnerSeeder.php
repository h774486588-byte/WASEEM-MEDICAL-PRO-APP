<?php

namespace Database\Seeders;

use App\Models\Branch;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;
use RuntimeException;

class InitialOwnerSeeder extends Seeder
{
    public function run(): void
    {
        $name = trim((string) env('WASEEM_INITIAL_OWNER_NAME', ''));
        $username = Str::lower(trim((string) env('WASEEM_INITIAL_OWNER_USERNAME', '')));
        $password = (string) env('WASEEM_INITIAL_OWNER_PASSWORD', '');

        if ($name === '' || ! preg_match('/^[a-z0-9._-]{3,100}$/', $username) || strlen($password) < 12) {
            throw new RuntimeException(
                'Set WASEEM_INITIAL_OWNER_NAME, WASEEM_INITIAL_OWNER_USERNAME and a strong WASEEM_INITIAL_OWNER_PASSWORD (at least 12 characters) before seeding the first owner.'
            );
        }

        if (User::query()->where('username', $username)->exists()) {
            return;
        }

        $branchName = trim((string) env('WASEEM_INITIAL_BRANCH_NAME', 'الفرع الرئيسي'));
        $branch = Branch::query()->firstOrCreate(
            ['name' => $branchName],
            ['next_patient_number' => 1001],
        );

        User::create([
            'branch_id' => $branch->id,
            'name' => $name,
            'username' => $username,
            'password_hash' => $password,
            'role' => 'owner',
            'is_active' => true,
        ]);
    }
}
