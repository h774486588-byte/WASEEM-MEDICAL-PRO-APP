<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class TherapySession extends Model
{
    use HasUuids;

    protected $table = 'sessions';

    protected $fillable = [
        'patient_id', 'package_id', 'therapist', 'session_date',
        'session_time', 'status', 'notes', 'created_by',
    ];

    protected function casts(): array
    {
        return ['session_date' => 'date'];
    }

    public function patient()
    {
        return $this->belongsTo(Patient::class);
    }

    public function package()
    {
        return $this->belongsTo(MedicalPackage::class, 'package_id');
    }
}
