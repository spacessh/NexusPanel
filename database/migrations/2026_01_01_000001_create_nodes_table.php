<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('nodes', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('fqdn');
            $table->string('ip');
            $table->unsignedSmallInteger('port')->default(8080);
            $table->string('token', 64)->unique();
            $table->unsignedBigInteger('memory');
            $table->unsignedBigInteger('disk');
            $table->integer('memory_overallocate')->default(0);
            $table->integer('disk_overallocate')->default(0);
            $table->boolean('is_public')->default(true);
            $table->string('location')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('nodes');
    }
};
