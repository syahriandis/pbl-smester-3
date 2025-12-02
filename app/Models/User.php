<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = [
        'userID',
        'password',
        'name',
        'gender',
        'phone',
        'photo',
        'role',
        'address', 
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    public function families()
    {
        return $this->hasMany(Family::class);
    }
}