<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('servers', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->string('name');
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('node_id')->constrained()->cascadeOnDelete();
            $table->string('game_type');
            $table->enum('status', ['offline', 'online', 'starting', 'stopping'])->default('offline');
            $table->unsignedBigInteger('memory');
            $table->unsignedBigInteger('disk');
            $table->unsignedInteger('cpu')->default(0);
            $table->string('ip');
            $table->unsignedSmallInteger('port');
            $table->text('startup_command');
            $table->json('environment')->nullable();
            $table->string('wings_id')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('servers');
    }
};
