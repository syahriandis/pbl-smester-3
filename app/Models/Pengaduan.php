<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\JenisPengaduan;
use App\Models\User;

class Pengaduan extends Model
{
    use HasFactory;

    protected $table = 'pengaduans';
    protected $primaryKey = 'id_pengaduan';

    protected $fillable = [
        'id_user',
        'id_jenis_pengaduan',
        'isi_pengaduan',
        'foto_bukti',
        'status_pengaduan',
    ];

    // Relasi ke User
    public function user()
    {
        return $this->belongsTo(User::class, 'id_user');
    }

    // Relasi ke Jenis Pengaduan
    public function jenisPengaduan()
    {
        return $this->belongsTo(JenisPengaduan::class, 'id_jenis_pengaduan');
    }
}