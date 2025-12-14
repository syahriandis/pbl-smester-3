<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
{
    Schema::table('surat_pengajuan', function (Blueprint $table) {
        $table->text('keperluan')->nullable()->after('file_surat');
    });
}

public function down()
{
    Schema::table('surat_pengajuan', function (Blueprint $table) {
        $table->dropColumn('keperluan');
    });
}
};
