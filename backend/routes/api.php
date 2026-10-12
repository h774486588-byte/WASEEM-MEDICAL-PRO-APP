<?php

use App\Http\Controllers\Api\AppointmentController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\InvoiceController;
use App\Http\Controllers\Api\PackageController;
use App\Http\Controllers\Api\PatientController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\SessionController;
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
    Route::apiResource('patients', PatientController::class);
    Route::apiResource('appointments', AppointmentController::class)->except(['destroy']);
    Route::apiResource('packages', PackageController::class)->only(['index', 'store', 'show']);
    Route::post('/packages/{package}/sessions', [SessionController::class, 'store']);
    Route::apiResource('invoices', InvoiceController::class)->only(['index', 'store', 'show']);
    Route::post('/invoices/{invoice}/payments', [InvoiceController::class, 'recordPayment']);
    Route::get('/reports/dashboard', ReportController::class);
});
