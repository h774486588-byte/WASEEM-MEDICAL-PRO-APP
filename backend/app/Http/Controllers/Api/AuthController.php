<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'username' => ['required', 'string', 'max:100'],
            'password' => ['required', 'string', 'max:1024'],
            'device_name' => ['nullable', 'string', 'max:120'],
        ]);

        $username = Str::lower(trim($credentials['username']));
        $user = User::query()->where('username', $username)->first();

        if (! $user || ! $user->is_active || ! Hash::check($credentials['password'], $user->password_hash)) {
            AuditLog::create([
                'user_id' => $user?->id,
                'branch_id' => $user?->branch_id,
                'action' => 'auth.login.failed',
                'entity' => 'user',
                'entity_id' => $user?->id,
                'details' => ['username' => $username],
                'created_at' => now(),
            ]);

            return response()->json([
                'message' => 'بيانات الدخول غير صحيحة أو الحساب غير نشط.',
            ], 401);
        }

        if (! $user->branch_id) {
            return response()->json([
                'message' => 'الحساب غير مرتبط بفرع. اربط الحساب بفرع قبل استخدام النظام.',
            ], 403);
        }

        $user->forceFill(['last_login_at' => now()])->save();
        $token = $user->createToken(
            $credentials['device_name'] ?? 'WASEEM Medical Mobile',
            ['*'],
            now()->addDays(7),
        );

        AuditLog::create([
            'user_id' => $user->id,
            'branch_id' => $user->branch_id,
            'action' => 'auth.login.succeeded',
            'entity' => 'user',
            'entity_id' => $user->id,
            'details' => ['device_name' => $credentials['device_name'] ?? 'WASEEM Medical Mobile'],
            'created_at' => now(),
        ]);

        return response()->json([
            'token_type' => 'Bearer',
            'access_token' => $token->plainTextToken,
            'expires_at' => now()->addDays(7)->toIso8601String(),
            'user' => $this->userPayload($user),
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json(['user' => $this->userPayload($request->user())]);
    }

    public function logout(Request $request): JsonResponse
    {
        $user = $request->user();
        $token = $user?->currentAccessToken();

        if ($token && method_exists($token, 'delete')) {
            $token->delete();
        }

        if ($user) {
            AuditLog::create([
                'user_id' => $user->id,
                'branch_id' => $user->branch_id,
                'action' => 'auth.logout',
                'entity' => 'user',
                'entity_id' => $user->id,
                'created_at' => now(),
            ]);
        }

        return response()->json(['message' => 'تم تسجيل الخروج بنجاح.']);
    }

    private function userPayload(User $user): array
    {
        return [
            'id' => $user->id,
            'branch_id' => $user->branch_id,
            'name' => $user->name,
            'username' => $user->username,
            'role' => $user->role,
            'is_active' => $user->is_active,
        ];
    }
}
