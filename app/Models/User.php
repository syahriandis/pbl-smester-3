<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use App\Models\Pengaduan;
use App\Models\Family;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = [
        'userID',
        'password',
        'name',
        'nik',
        'gender',
        'phone',
        'photo',
        'role',
        'address',
        'nik',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

   public function families()
    {
        return $this->hasMany(\App\Models\Family::class, 'user_id');
<<<<<<< HEAD
=======
    }
    public function pengaduans()
    {
        return $this->hasMany(Pengaduan::class, 'id_user');
>>>>>>> main
    }
}