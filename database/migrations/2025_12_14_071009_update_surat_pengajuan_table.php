<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('surat_pengajuan', function (Blueprint $table) {
            if (!Schema::hasColumn('surat_pengajuan', 'file_surat')) {
                $table->string('file_surat')->nullable()->after('catatan_rt');
            }
        });

        DB::statement("ALTER TABLE surat_pengajuan MODIFY status ENUM('pending', 'disetujui', 'ditolak', 'selesai') DEFAULT 'pending'");
        if (Schema::hasColumn('surat_pengajuan', 'data_final')) {
            Schema::table('surat_pengajuan', function (Blueprint $table) {
                $table->dropColumn('data_final');
            });
        }
    }

    public function down(): void
    {
        Schema::table('surat_pengajuan', function (Blueprint $table) {
            $table->dropColumn('file_surat');
            $table->json('data_final')->nullable();
        });

        DB::statement("ALTER TABLE surat_pengajuan MODIFY status ENUM('pending', 'diproses', 'selesai') DEFAULT 'pending'");
    }
};