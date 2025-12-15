<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('surat_pengajuan', function (Blueprint $table) {
            $table->id('id_pengajuan');

            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('id_jenis_surat');

            $table->date('tanggal_pengajuan');
            $table->enum('status', ['pending', 'diproses', 'selesai'])->default('pending');
            $table->text('catatan_rt')->nullable();
            $table->json('data_final')->nullable();
            $table->timestamps();

            // ✅ FK ke users.id
            $table->foreign('user_id')
                  ->references('id')
                  ->on('users')
                  ->onDelete('cascade');

            // ✅ FK ke jenis_surat.id (INI YANG PENTING)
            $table->foreign('id_jenis_surat')
                  ->references('id')
                  ->on('jenis_surat')
                  ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('surat_pengajuan');
    }
};