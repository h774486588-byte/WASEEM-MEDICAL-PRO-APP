<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class PayrollEntry extends Model
{
    use HasUuids;

    protected $fillable = [
        'staff_id', 'entry_type', 'month', 'amount', 'method', 'paid_at', 'notes', 'created_by',
    ];

    protected function casts(): array
    {
        return ['amount' => 'decimal:2', 'paid_at' => 'datetime'];
    }

    public function staff()
    {
        return $this->belongsTo(MedicalStaff::class, 'staff_id');
    }
}
