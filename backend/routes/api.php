<?php

use App\Http\Controllers\Api\AppointmentController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ExpenseController;
use App\Http\Controllers\Api\InvoiceController;
use App\Http\Controllers\Api\PackageController;
use App\Http\Controllers\Api\PayrollController;
use App\Http\Controllers\Api\PatientController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\SessionController;
use App\Http\Controllers\Api\StaffController;
use Illuminate\Support\Facades\Route;

Route::get('/health', fn () => response()->json([
    'name' => config('app.name'),
    'status' => 'ok',
    'time' => now()->toIso8601String(),
]));

Route::prefix('auth')->group(function (): void {
    Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:auth');
    Route::middleware('auth:sanctum')->group(function (): void {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
});

Route::middleware('auth:sanctum')->group(function (): void {
    Route::apiResource('patients', PatientController::class)
        ->except(['destroy'])
        ->middleware('role:owner,admin,reception,therapist,accountant');
    Route::delete('/patients/{patient}', [PatientController::class, 'destroy'])
        ->middleware('role:owner,admin');

    Route::apiResource('appointments', AppointmentController::class)
        ->except(['destroy'])
        ->middleware('role:owner,admin,reception,therapist');

    Route::apiResource('packages', PackageController::class)
        ->only(['index', 'store', 'show'])
        ->middleware('role:owner,admin,reception,therapist,accountant');
    Route::post('/packages/{package}/sessions', [SessionController::class, 'store'])
        ->middleware('role:owner,admin,therapist');

    Route::apiResource('invoices', InvoiceController::class)
        ->only(['index', 'store', 'show'])
        ->middleware('role:owner,admin,reception,accountant');
    Route::post('/invoices/{invoice}/payments', [InvoiceController::class, 'recordPayment'])
        ->middleware('role:owner,admin,accountant');

    Route::apiResource('expenses', ExpenseController::class)
        ->middleware('role:owner,admin,accountant');

    Route::apiResource('staff', StaffController::class)
        ->middleware('role:owner,admin');

    Route::get('/attendance', [AttendanceController::class, 'index'])
        ->middleware('role:owner,admin,reception');
    Route::post('/staff/{staff}/attendance', [AttendanceController::class, 'store'])
        ->middleware('role:owner,admin,reception');

    Route::get('/payroll', [PayrollController::class, 'index'])
        ->middleware('role:owner,admin,accountant');
    Route::post('/staff/{staff}/payroll', [PayrollController::class, 'store'])
        ->middleware('role:owner,admin,accountant');

    Route::get('/reports/dashboard', ReportController::class)
        ->middleware('role:owner,admin,accountant');
});
