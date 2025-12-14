<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
{
    Schema::table('surat_pengajuan', function (Blueprint $table) {
        if (!Schema::hasColumn('surat_pengajuan', 'keperluan')) {
            $table->text('keperluan')->nullable()->after('file_surat');
        }
    });
}

public function down()
{
    Schema::table('surat_pengajuan', function (Blueprint $table) {
        if (Schema::hasColumn('surat_pengajuan', 'keperluan')) {
            $table->dropColumn('keperluan');
        }
    });
}
};
