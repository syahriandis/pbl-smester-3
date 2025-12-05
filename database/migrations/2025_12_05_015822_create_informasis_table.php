<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('informasis', function (Blueprint $table) {
            $table->id();

            // RT / RW yang membuat informasi
            $table->unsignedBigInteger('user_id');

            // Data informasi
            $table->string('title');
            $table->string('image')->nullable(); // file/foto
            $table->date('date');               // tanggal kegiatan
            $table->time('time')->nullable();   // jam kegiatan
            $table->string('day')->nullable();  // hari kegiatan
            $table->string('location');         // lokasi
            $table->text('description')->nullable();

            $table->timestamps();

            // Relasi ke users
            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('informasis');
    }
};