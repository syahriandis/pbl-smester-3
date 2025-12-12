<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SuratPengajuan extends Model
{
    use HasFactory;

    protected $table = 'surat_pengajuan';
    protected $primaryKey = 'id_pengajuan';

    protected $fillable = [
        'user_id',
        'id_jenis_surat',
        'tanggal_pengajuan',
        'status',
        'catatan_rt',
        'data_final'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }

    public function jenisSurat()
    {
        return $this->belongsTo(JenisSurat::class, 'id_jenis_surat', 'id');
    }
}   