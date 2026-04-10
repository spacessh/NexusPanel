<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('server_stats', function (Blueprint $table) {
            $table->id();
            $table->foreignId('server_id')->constrained()->cascadeOnDelete();
            $table->float('cpu_absolute')->default(0);
            $table->unsignedBigInteger('memory_bytes')->default(0);
            $table->unsignedBigInteger('memory_limit_bytes')->default(0);
            $table->unsignedBigInteger('disk_bytes')->default(0);
            $table->unsignedBigInteger('network_rx_bytes')->default(0);
            $table->unsignedBigInteger('network_tx_bytes')->default(0);
            $table->timestamp('recorded_at')->useCurrent();

            $table->index(['server_id', 'recorded_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('server_stats');
    }
};
