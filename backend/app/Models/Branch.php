<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Branch extends Model
{
    use HasUuids;

    protected $fillable = ['name', 'phone', 'address', 'next_patient_number'];

    protected function casts(): array
    {
        return ['next_patient_number' => 'integer'];
    }

    public function users()
    {
        return $this->hasMany(User::class);
    }
}
