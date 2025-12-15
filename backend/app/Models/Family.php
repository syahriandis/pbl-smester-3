<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Family extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'nama',
        'hubungan',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}