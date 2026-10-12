<?php

use Illuminate\Support\Facades\Artisan;

Artisan::command('waseem:health', function (): void {
    $this->info('WASEEM MEDICAL PRO API console is available.');
})->purpose('Check that the WASEEM API artisan command runner is available');
