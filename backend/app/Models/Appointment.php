<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Appointment extends Model
{
    use HasUuids;

    protected $fillable = ['patient_id', 'doctor', 'appointment_date', 'appointment_time', 'status', 'notes'];

    protected function casts(): array
    {
        return ['appointment_date' => 'date'];
    }

    public function patient()
    {
        return $this->belongsTo(Patient::class);
    }
}
