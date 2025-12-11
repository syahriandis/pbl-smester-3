<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Pengaduan;

class JenisPengaduan extends Model
{
    use HasFactory;

    protected $table = 'jenis_pengaduans';
    
    protected $fillable = [
        'nama_jenis_pengaduan', 
    ];

    /**
     * Relasi: Satu Jenis Pengaduan bisa memiliki BANYAK Pengaduan
     */
    public function pengaduans()
    {
        return $this->hasMany(Pengaduan::class, 'id_jenis_pengaduan');
    }
}
