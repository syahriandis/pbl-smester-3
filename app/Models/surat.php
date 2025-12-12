<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class surat extends Model
{
    use HasFactory;

    protected $table = 'surats';
    protected $primaryKey = 'id_surat';

    protected $fillable = [
        'id_user',          
        'id_jenis_surat',
        'status_surat',     
        'tanggal_pengajuan',
        'keterangan',
        'disetujui_oleh'  
    ];

    protected $casts = [
        'tanggal_pengajuan' => 'date',
    ];

    public function pengaju()
    {
        return $this->belongsTo(User::class, 'id_user', 'id');
    }

    public function penyetuju()
    {
        return $this->belongsTo(User::class, 'disetujui_oleh', 'id');
    }

    public function jenisSurat()
    {
        return $this->belongsTo(JenisSurat::class, 'id_jenis_surat', 'id_jenis_surat');
    }
}
