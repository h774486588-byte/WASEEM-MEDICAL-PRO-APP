<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Invoice extends Model
{
    use HasUuids;

    protected $fillable = ['patient_id', 'invoice_no', 'total', 'paid', 'status', 'issued_at'];

    protected function casts(): array
    {
        return [
            'total' => 'decimal:2',
            'paid' => 'decimal:2',
            'issued_at' => 'datetime',
        ];
    }

    public function getRemainingAttribute(): string
    {
        return number_format(max(0, (float) $this->total - (float) $this->paid), 2, '.', '');
    }

    public function patient()
    {
        return $this->belongsTo(Patient::class);
    }

    public function payments()
    {
        return $this->hasMany(Payment::class);
    }
}
