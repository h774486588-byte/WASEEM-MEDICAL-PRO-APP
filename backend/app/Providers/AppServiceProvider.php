<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        RateLimiter::for('api', fn (Request $request) => Limit::perMinute(120)->by(
            (string) ($request->user()?->getAuthIdentifier() ?? $request->ip())
        ));

        RateLimiter::for('auth', fn (Request $request) => Limit::perMinute(5)->by(
            strtolower((string) $request->input('username')).'|'.$request->ip()
        ));
    }
}
