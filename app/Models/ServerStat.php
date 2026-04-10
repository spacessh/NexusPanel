<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ServerStat extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'server_id', 'cpu_absolute',
        'memory_bytes', 'memory_limit_bytes',
        'disk_bytes', 'network_rx_bytes', 'network_tx_bytes',
        'recorded_at',
    ];

    protected $casts = [
        'cpu_absolute'         => 'float',
        'memory_bytes'         => 'integer',
        'memory_limit_bytes'   => 'integer',
        'disk_bytes'           => 'integer',
        'network_rx_bytes'     => 'integer',
        'network_tx_bytes'     => 'integer',
        'recorded_at'          => 'datetime',
    ];

    public function server(): BelongsTo
    {
        return $this->belongsTo(Server::class);
    }
}
