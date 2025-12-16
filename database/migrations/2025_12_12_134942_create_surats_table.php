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
        Schema::create('surats', function (Blueprint $table) {
            $table->id('id_surat');
            $table->unsignedBigInteger('id_user');
            $table->foreign('id_user')->references('id')->on('users')->onDelete('cascade');
            $table->unsignedBigInteger('id_jenis_surat');
            $table->foreign('id_jenis_surat')->references('id_jenis_surat')->on('jenis_surats');
            $table->string('status_surat')->default('Pending');
            $table->date('tanggal_pengajuan');
            $table->text('keterangan')->nullable(); 
            $table->unsignedBigInteger('disetujui_oleh')->nullable();
            $table->foreign('disetujui_oleh')->references('id')->on('users');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('surats');
    }
};
