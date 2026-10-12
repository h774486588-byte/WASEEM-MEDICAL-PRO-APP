<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class AuditLog extends Model
{
    use HasUuids;

    public $timestamps = false;

    protected $fillable = ['user_id', 'branch_id', 'action', 'entity', 'entity_id', 'details', 'created_at'];

    protected function casts(): array
    {
        return ['details' => 'array', 'created_at' => 'datetime'];
    }
}
