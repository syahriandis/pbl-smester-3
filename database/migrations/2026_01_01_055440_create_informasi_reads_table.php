<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
{
    Schema::create('informasi_reads', function (Blueprint $table) {
        $table->id();

        $table->unsignedBigInteger('informasi_id');
        $table->unsignedBigInteger('user_id');

        $table->timestamp('read_at')->nullable();

        $table->timestamps();

        $table->foreign('informasi_id')
            ->references('id')
            ->on('informasis')
            ->onDelete('cascade');

        $table->foreign('user_id')
            ->references('id')
            ->on('users')
            ->onDelete('cascade');

        $table->unique(['informasi_id', 'user_id']);
    });
}

    public function down(): void
    {
        Schema::dropIfExists('informasi_reads');
    }
};
