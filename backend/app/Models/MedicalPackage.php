<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class MedicalPackage extends Model
{
    use HasUuids;

    protected $table = 'packages';

    protected $fillable = [
        'patient_id', 'name', 'price', 'paid', 'sessions_count',
        'remaining_sessions', 'start_date', 'end_date',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'paid' => 'decimal:2',
            'sessions_count' => 'integer',
            'remaining_sessions' => 'integer',
            'start_date' => 'date',
            'end_date' => 'date',
        ];
    }

    public function patient()
    {
        return $this->belongsTo(Patient::class);
    }

    public function sessions()
    {
        return $this->hasMany(TherapySession::class, 'package_id');
    }
}
