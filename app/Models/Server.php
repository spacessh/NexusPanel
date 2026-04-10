<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Server extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'uuid', 'user_id', 'node_id',
        'game_type', 'status',
        'memory', 'disk', 'cpu',
        'ip', 'port',
        'startup_command', 'environment',
        'wings_id',
    ];

    protected $casts = [
        'environment' => 'array',
        'memory'      => 'integer',
        'disk'        => 'integer',
        'cpu'         => 'integer',
        'port'        => 'integer',
    ];

    // Status constants
    const STATUS_OFFLINE  = 'offline';
    const STATUS_ONLINE   = 'online';
    const STATUS_STARTING = 'starting';
    const STATUS_STOPPING = 'stopping';

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function node(): BelongsTo
    {
        return $this->belongsTo(Node::class);
    }

    public function backups(): HasMany
    {
        return $this->hasMany(ServerBackup::class);
    }

    public function logs(): HasMany
    {
        return $this->hasMany(ServerLog::class);
    }

    public function stats(): HasMany
    {
        return $this->hasMany(ServerStat::class);
    }

    public function isOnline(): bool
    {
        return $this->status === self::STATUS_ONLINE;
    }
}
