<?php

use Illuminate\Support\Facades\Broadcast;
use App\Models\Server;

/*
|--------------------------------------------------------------------------
| NexusPanel WebSocket Channels
|--------------------------------------------------------------------------
*/

// Server console output channel
Broadcast::channel('server.{serverId}.console', function ($user, $serverId) {
    $server = Server::find($serverId);
    return $server && ($user->id === $server->user_id || $user->hasRole('admin'));
});

// Server stats channel
Broadcast::channel('server.{serverId}.stats', function ($user, $serverId) {
    $server = Server::find($serverId);
    return $server && ($user->id === $server->user_id || $user->hasRole('admin'));
});

// Global admin channel
Broadcast::channel('nexus.admin', function ($user) {
    return $user->hasRole('admin');
});
