<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Patient extends Model
{
    use HasUuids, SoftDeletes;

    protected $fillable = [
        'branch_id', 'file_no', 'name', 'phone', 'national_id', 'birth_date', 'gender',
        'department', 'service', 'doctor', 'alternate_phone', 'address', 'notes', 'created_by',
    ];

    protected function casts(): array
    {
        return ['birth_date' => 'date'];
    }

    public function appointments()
    {
        return $this->hasMany(Appointment::class);
    }

    public function packages()
    {
        return $this->hasMany(MedicalPackage::class);
    }

    public function invoices()
    {
        return $this->hasMany(Invoice::class);
    }

    public function sessions()
    {
        return $this->hasMany(TherapySession::class);
    }
}
