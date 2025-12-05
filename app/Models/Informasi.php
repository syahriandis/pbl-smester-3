<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Informasi extends Model
{
    use HasFactory;

    protected $table = 'informasis';

    protected $fillable = [
        'user_id',
        'title',
        'image',
        'date',
        'time',
        'day',
        'location',
        'description'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}