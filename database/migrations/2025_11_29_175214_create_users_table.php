<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('userID')->unique();
            $table->string('password');
            $table->string('name');
            $table->string('nik', 16)->unique()->nullable();
            $table->text('address')->nullable();
            $table->enum('gender', ['male', 'female'])->nullable();
            $table->string('phone')->nullable();
            $table->string('photo')->nullable();
            $table->enum('role', ['admin', 'warga', 'security', 'rt', 'rw'])->default('warga');
            $table->timestamps();
        });
    }
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
