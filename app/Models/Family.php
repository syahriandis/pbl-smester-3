<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Family extends Model
{
    protected $fillable = ['user_id', 'nama', 'hubungan'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}