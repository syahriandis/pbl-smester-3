<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pembayaran', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->enum('role', ['warga', 'rt', 'rw', 'security']);
            $table->decimal('nominal', 10, 2)->default(110000.00);
            $table->integer('bulan'); // 1-12
            $table->integer('tahun'); // 2024, 2025, dst
            $table->enum('metode_pembayaran', ['qris', 'transfer']);
            $table->string('bukti_pembayaran')->nullable(); // path file
            $table->enum('status', ['belum_bayar', 'menunggu_verifikasi', 'sudah_bayar', 'ditolak'])->default('belum_bayar');
            $table->text('catatan_admin')->nullable();
            $table->timestamp('tanggal_bayar')->nullable();
            $table->timestamp('tanggal_verifikasi')->nullable();
            $table->timestamps();
            
            // Unique constraint: satu user hanya bisa bayar sekali per bulan per tahun
            $table->unique(['user_id', 'bulan', 'tahun']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pembayaran');
    }
};