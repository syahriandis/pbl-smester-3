<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class JenisSuratSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $data = [
            ['nama_jenis_surat' => 'Surat Pengantar KTP'],
            ['nama_jenis_surat' => 'Surat Pengantar KK'],
            ['nama_jenis_surat' => 'Surat Keterangan Domisili'],
            ['nama_jenis_surat' => 'Surat Keterangan Usaha (SKU)'],
            ['nama_jenis_surat' => 'Surat Keterangan Tidak Mampu (SKTM)'],
            ['nama_jenis_surat' => 'Surat Keterangan Berkelakuan Baik (SKCK)'],
            ['nama_jenis_surat' => 'Surat Keterangan Kelahiran'],
            ['nama_jenis_surat' => 'Surat Keterangan Kematian'],
            ['nama_jenis_surat' => 'Surat Izin Keramaian'],
            ['nama_jenis_surat' => 'Surat Pindah Penduduk'],
        ];

        foreach ($data as $item) {
            DB::table('jenis_surats')->insert([
                'nama_jenis_surat' => $item['nama_jenis_surat'],
                'created_at'       => Carbon::now(),
                'updated_at'       => Carbon::now(),
            ]);
        }
    }
}
