<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Node extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'fqdn', 'ip', 'port',
        'token', 'memory', 'disk',
        'memory_overallocate', 'disk_overallocate',
        'is_public', 'location',
    ];

    protected $hidden = ['token'];

    protected $casts = [
        'memory'               => 'integer',
        'disk'                 => 'integer',
        'memory_overallocate'  => 'integer',
        'disk_overallocate'    => 'integer',
        'is_public'            => 'boolean',
    ];

    public function servers(): HasMany
    {
        return $this->hasMany(Server::class);
    }

    public function getWingsUrl(): string
    {
        return "https://{$this->fqdn}:{$this->port}";
    }
}
