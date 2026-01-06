<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Rental extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'guest_name',
        'guest_phone',
        'guest_address',
        'costume_id',
        'start_date',
        'expected_return_date',
        'returned_at',
        'total_price',
    ];

    protected $casts = [
        'start_date' => 'date',
        'expected_return_date' => 'date',
        'returned_at' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function costume()
    {
        return $this->belongsTo(Costume::class);
    }
}
