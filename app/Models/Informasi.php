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

    // RT/RW pembuat informasi
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // User yang sudah membaca
    public function readers()
    {
        return $this->belongsToMany(
            User::class,
            'informasi_reads',
            'informasi_id',
            'user_id'
        )->withPivot('read_at')->withTimestamps();
    }
}
