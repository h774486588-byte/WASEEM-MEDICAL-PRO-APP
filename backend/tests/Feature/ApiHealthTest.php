<?php

namespace Tests\Feature;

use Tests\TestCase;

class ApiHealthTest extends TestCase
{
    public function test_health_endpoint_is_public_and_returns_json(): void
    {
        $this->getJson('/api/health')
            ->assertOk()
            ->assertJsonPath('status', 'ok')
            ->assertJsonStructure(['name', 'status', 'time']);
    }

    public function test_private_patient_endpoint_requires_authentication(): void
    {
        $this->getJson('/api/patients')->assertUnauthorized();
    }
}
