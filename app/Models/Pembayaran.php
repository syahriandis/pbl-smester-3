<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pembayaran extends Model
{
    use HasFactory;

    protected $table = 'pembayaran';

    protected $fillable = [
        'user_id',
        'role',
        'nominal',
        'bulan',
        'tahun',
        'metode_pembayaran',
        'bukti_pembayaran',
        'status',
        'catatan_admin',
        'tanggal_bayar',
        'tanggal_verifikasi',
    ];

    protected $casts = [
        'tanggal_bayar' => 'datetime',
        'tanggal_verifikasi' => 'datetime',
    ];

    // Relasi ke User
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Scope untuk filter per bulan dan tahun
    public function scopeByPeriode($query, $bulan, $tahun)
    {
        return $query->where('bulan', $bulan)->where('tahun', $tahun);
    }

    // Scope untuk filter by status
    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }
}