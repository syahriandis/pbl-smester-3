<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('pengaduan', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // warga pengadu
            $table->string('title');
            $table->string('location')->nullable();
            $table->text('description');
            $table->string('image')->nullable(); // path gambar
            $table->enum('status', ['pending', 'approved', 'rejected', 'in_progress', 'done'])->default('pending');
            $table->text('feedback')->nullable(); // catatan dari security
            $table->timestamps();
        });
    }

    public function down(): void {
        Schema::dropIfExists('pengaduan');
    }
};