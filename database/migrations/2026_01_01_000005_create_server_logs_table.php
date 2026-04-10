<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('server_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('server_id')->constrained()->cascadeOnDelete();
            $table->enum('level', ['info', 'warn', 'error', 'success', 'system'])->default('info');
            $table->text('message');
            $table->timestamp('logged_at')->useCurrent();

            $table->index(['server_id', 'logged_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('server_logs');
    }
};
