<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Informasi extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'title',
        'description',
        'date',
        'day',
        'time',
        'location',
        'image',
    ];

    // Relasi ke user (RT/RW yang buat informasi)
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}