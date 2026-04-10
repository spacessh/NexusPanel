<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ServerLog extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'server_id', 'level', 'message', 'logged_at',
    ];

    protected $casts = [
        'logged_at' => 'datetime',
    ];

    public function server(): BelongsTo
    {
        return $this->belongsTo(Server::class);
    }
}
