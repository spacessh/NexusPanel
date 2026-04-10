<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ServerBackup extends Model
{
    use HasFactory;

    protected $fillable = [
        'server_id', 'uuid', 'name',
        'size', 'checksum', 'status',
        'completed_at',
    ];

    protected $casts = [
        'size'         => 'integer',
        'completed_at' => 'datetime',
    ];

    const STATUS_PENDING    = 'pending';
    const STATUS_RUNNING    = 'running';
    const STATUS_SUCCESSFUL = 'successful';
    const STATUS_FAILED     = 'failed';

    public function server(): BelongsTo
    {
        return $this->belongsTo(Server::class);
    }
}
