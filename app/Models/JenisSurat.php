<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class JenisSurat extends Model
{
    protected $table = 'jenis_surats';
    protected $primaryKey = 'id_jenis_surat';
    
    protected $fillable = [
        'nama_jenis_surat'
    ];

    public function surats()
    {
        return $this->hasMany(Surat::class, 'id_jenis_surat');
    }
}
