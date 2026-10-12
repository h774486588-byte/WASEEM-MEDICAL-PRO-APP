<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class MedicalStaff extends Model
{
    use HasUuids;

    protected $table = 'medical_staff';

    protected $fillable = [
        'branch_id', 'full_name', 'role', 'specialty', 'phone', 'email', 'monthly_salary', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'monthly_salary' => 'decimal:2',
            'is_active' => 'boolean',
        ];
    }

    public function attendanceRecords()
    {
        return $this->hasMany(AttendanceRecord::class, 'staff_id');
    }

    public function payrollEntries()
    {
        return $this->hasMany(PayrollEntry::class, 'staff_id');
    }
}
