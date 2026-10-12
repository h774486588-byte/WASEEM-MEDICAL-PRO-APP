<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('medical_staff', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('branch_id')->constrained('branches')->cascadeOnDelete();
            $table->string('full_name', 200);
            $table->string('role', 80)->default('staff');
            $table->string('specialty', 150)->nullable();
            $table->string('phone', 40)->nullable();
            $table->string('email', 200)->nullable();
            $table->decimal('monthly_salary', 14, 2)->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestampsTz();
            $table->index(['branch_id', 'is_active']);
        });

        Schema::create('attendance_records', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('staff_id')->constrained('medical_staff')->cascadeOnDelete();
            $table->date('attendance_date');
            $table->string('status', 30);
            $table->time('check_in')->nullable();
            $table->text('notes')->nullable();
            $table->foreignUuid('recorded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestampsTz();
            $table->unique(['staff_id', 'attendance_date']);
            $table->index('attendance_date');
        });

        Schema::create('payroll_entries', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('staff_id')->constrained('medical_staff')->cascadeOnDelete();
            $table->string('entry_type', 30);
            $table->char('month', 7);
            $table->decimal('amount', 14, 2);
            $table->string('method', 30)->default('cash');
            $table->timestampTz('paid_at')->useCurrent();
            $table->text('notes')->nullable();
            $table->foreignUuid('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestampsTz();
            $table->index(['staff_id', 'month']);
            $table->index('paid_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payroll_entries');
        Schema::dropIfExists('attendance_records');
        Schema::dropIfExists('medical_staff');
    }
};
