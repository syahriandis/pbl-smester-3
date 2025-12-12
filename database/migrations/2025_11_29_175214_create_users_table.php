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
            $table->enum('gender', ['LAKI-LAKI', 'PEREMPUAN'])->nullable();
            $table->string('phone')->nullable();
            $table->string('photo')->nullable();
            $table->string('role')->default('user');    
            $table->timestamps();
        });
    }
};
