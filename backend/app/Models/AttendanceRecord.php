<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class AttendanceRecord extends Model
{
    use HasUuids;

    protected $fillable = [
        'staff_id', 'attendance_date', 'status', 'check_in', 'notes', 'recorded_by',
    ];

    protected function casts(): array
    {
        return ['attendance_date' => 'date'];
    }

    public function staff()
    {
        return $this->belongsTo(MedicalStaff::class, 'staff_id');
    }
}
