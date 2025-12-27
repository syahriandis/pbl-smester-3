<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pengaduan extends Model
{
    use HasFactory;

    protected $table = 'pengaduan';

    // Kolom yang bisa diisi
    protected $fillable = [
        'user_id',
        'title',
        'location',
        'description',
        'image',
        'status',
        'feedback',
    ];

    // Relasi ke User (warga yang buat pengaduan)
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}