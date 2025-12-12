<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class JenisSurat extends Model
{
    use HasFactory;

    protected $table = 'jenis_surat';
    protected $primaryKey = 'id_jenis_surat';

    protected $fillable = [
        'nama_jenis_surat'
    ];

    public function pengajuan()
    {
        return $this->hasMany(SuratPengajuan::class, 'id_jenis_surat');
    }
}