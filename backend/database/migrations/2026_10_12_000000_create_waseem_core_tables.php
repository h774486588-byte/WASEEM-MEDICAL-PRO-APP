<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('branches', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->string('name', 150);
            $table->string('phone', 30)->nullable();
            $table->text('address')->nullable();
            $table->unsignedInteger('next_patient_number')->default(1001);
            $table->timestampsTz();
        });

        Schema::create('users', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('branch_id')->nullable()->constrained('branches')->nullOnDelete();
            $table->string('name', 150);
            $table->string('username', 100)->unique();
            $table->text('password_hash');
            $table->string('role', 30)->default('reception');
            $table->boolean('is_active')->default(true);
            $table->timestampTz('last_login_at')->nullable();
            $table->timestampsTz();
        });

        Schema::create('patients', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('branch_id')->nullable()->constrained('branches')->nullOnDelete();
            $table->string('file_no', 30)->unique();
            $table->string('name', 200);
            $table->string('phone', 40);
            $table->string('national_id', 80)->nullable();
            $table->date('birth_date')->nullable();
            $table->string('gender', 20)->nullable();
            $table->string('department', 150)->nullable();
            $table->string('service', 200)->nullable();
            $table->string('doctor', 200)->nullable();
            $table->string('alternate_phone', 40)->nullable();
            $table->text('address')->nullable();
            $table->text('notes')->nullable();
            $table->foreignUuid('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index('phone');
            $table->index(['branch_id', 'name']);
        });

        Schema::create('appointments', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('patient_id')->constrained('patients')->cascadeOnDelete();
            $table->string('doctor', 200)->nullable();
            $table->date('appointment_date');
            $table->time('appointment_time');
            $table->string('status', 30)->default('confirmed');
            $table->text('notes')->nullable();
            $table->timestampsTz();
            $table->index('appointment_date');
            $table->index(['patient_id', 'appointment_date']);
        });

        Schema::create('packages', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('patient_id')->constrained('patients')->cascadeOnDelete();
            $table->string('name', 200);
            $table->decimal('price', 14, 2)->default(0);
            $table->decimal('paid', 14, 2)->default(0);
            $table->unsignedInteger('sessions_count')->default(0);
            $table->unsignedInteger('remaining_sessions')->default(0);
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->timestampsTz();
            $table->index('patient_id');
            $table->check('remaining_sessions <= sessions_count');
        });

        Schema::create('sessions', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('patient_id')->constrained('patients')->cascadeOnDelete();
            $table->foreignUuid('package_id')->nullable()->constrained('packages')->nullOnDelete();
            $table->string('therapist', 200)->nullable();
            $table->date('session_date');
            $table->time('session_time')->nullable();
            $table->string('status', 30)->default('attended');
            $table->text('notes')->nullable();
            $table->foreignUuid('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestampsTz();
            $table->index(['patient_id', 'session_date']);
        });

        Schema::create('invoices', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('patient_id')->constrained('patients')->cascadeOnDelete();
            $table->string('invoice_no', 50)->unique();
            $table->decimal('total', 14, 2)->default(0);
            $table->decimal('paid', 14, 2)->default(0);
            $table->string('status', 30)->default('unpaid');
            $table->timestampTz('issued_at')->useCurrent();
            $table->timestampsTz();
            $table->index('patient_id');
        });

        Schema::create('payments', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('invoice_id')->constrained('invoices')->cascadeOnDelete();
            $table->decimal('amount', 14, 2);
            $table->string('method', 30)->default('cash');
            $table->timestampTz('paid_at')->useCurrent();
            $table->text('notes')->nullable();
            $table->index(['invoice_id', 'paid_at']);
        });

        Schema::create('expenses', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('branch_id')->nullable()->constrained('branches')->nullOnDelete();
            $table->string('category', 100);
            $table->text('description')->nullable();
            $table->decimal('amount', 14, 2);
            $table->string('payment_method', 30)->default('cash');
            $table->date('expense_date')->useCurrent();
            $table->foreignUuid('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestampsTz();
            $table->index(['branch_id', 'expense_date']);
        });

        Schema::create('notifications', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('patient_id')->nullable()->constrained('patients')->nullOnDelete();
            $table->string('channel', 30);
            $table->string('event_type', 50);
            $table->string('recipient', 100)->nullable();
            $table->text('message');
            $table->string('status', 30)->default('queued');
            $table->timestampTz('scheduled_at')->nullable();
            $table->timestampTz('sent_at')->nullable();
            $table->timestampsTz();
            $table->index(['status', 'scheduled_at']);
        });

        Schema::create('personal_access_tokens', function (Blueprint $table): void {
            $table->bigIncrements('id');
            $table->uuidMorphs('tokenable');
            $table->string('name');
            $table->string('token', 64)->unique();
            $table->text('abilities')->nullable();
            $table->timestampTz('last_used_at')->nullable();
            $table->timestampTz('expires_at')->nullable();
            $table->timestampsTz();
        });

        Schema::create('audit_logs', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignUuid('branch_id')->nullable()->constrained('branches')->nullOnDelete();
            $table->string('action', 100);
            $table->string('entity', 100)->nullable();
            $table->uuid('entity_id')->nullable();
            $table->jsonb('details')->nullable();
            $table->timestampTz('created_at')->useCurrent();
            $table->index(['branch_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
        Schema::dropIfExists('personal_access_tokens');
        Schema::dropIfExists('notifications');
        Schema::dropIfExists('expenses');
        Schema::dropIfExists('payments');
        Schema::dropIfExists('invoices');
        Schema::dropIfExists('sessions');
        Schema::dropIfExists('packages');
        Schema::dropIfExists('appointments');
        Schema::dropIfExists('patients');
        Schema::dropIfExists('users');
        Schema::dropIfExists('branches');
    }
};
