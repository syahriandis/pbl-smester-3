<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('pengaduans', function (Blueprint $table) {
            $table->id('id_pengaduan');
            $table->foreignId('id_user')->constrained('users')->onDelete('cascade');
            $table->foreignId('id_jenis_pengaduan')->constrained('jenis_pengaduans');
            $table->text('isi_pengaduan');
            $table->string('foto_bukti')->nullable();
            $table->enum('status_pengaduan', ['pending', 'proses', 'selesai', 'ditolak'])->default('pending');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pengaduans');
    }
};
