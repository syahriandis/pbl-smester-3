<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SuratPengajuan extends Model
{
    protected $table = 'surat_pengajuan';
    protected $primaryKey = 'id_pengajuan';

    protected $fillable = [
        'user_id',
        'id_jenis_surat',
        'tanggal_pengajuan',
        'status',
        'catatan_rt',
        'file_surat',
        'keperluan'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function jenisSurat()
    {
        return $this->belongsTo(JenisSurat::class, 'id_jenis_surat');
    }
}