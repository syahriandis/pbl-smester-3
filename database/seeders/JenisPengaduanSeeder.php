<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\JenisPengaduan;

class JenisPengaduanSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $data = [
            ['nama_jenis_pengaduan' => 'Keamanan'],      // Maling, orang mencurigakan
            ['nama_jenis_pengaduan' => 'Kebersihan'],    // Sampah menumpuk, selokan mampet
            ['nama_jenis_pengaduan' => 'Infrastruktur'], // Jalan rusak, lampu jalan mati
            ['nama_jenis_pengaduan' => 'Sosial'],        // Keributan tetangga, acara liar
            ['nama_jenis_pengaduan' => 'Administrasi'],  // Masalah surat pengantar, KK
        ];
        foreach ($data as $item) {
            JenisPengaduan::create($item);
        }
    }
}
