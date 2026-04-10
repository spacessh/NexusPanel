<?php

namespace App\Http\Controllers;

use App\Models\Server;
use App\Models\ServerStat;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class MonitoringController extends Controller
{
    public function stats(Server $server): JsonResponse
    {
        $stats = ServerStat::where('server_id', $server->id)
            ->orderByDesc('recorded_at')
            ->limit(60)
            ->get(['cpu_absolute', 'memory_bytes', 'memory_limit_bytes', 'disk_bytes', 'network_rx_bytes', 'network_tx_bytes', 'recorded_at']);

        return response()->json($stats);
    }

    public function current(Server $server): JsonResponse
    {
        $latest = ServerStat::where('server_id', $server->id)
            ->latest('recorded_at')
            ->first();

        if (!$latest) {
            return response()->json(['error' => 'No stats available'], 404);
        }

        return response()->json([
            'cpu'     => round($latest->cpu_absolute, 2),
            'memory'  => [
                'current' => $latest->memory_bytes,
                'limit'   => $latest->memory_limit_bytes,
                'percent' => $latest->memory_limit_bytes > 0
                    ? round(($latest->memory_bytes / $latest->memory_limit_bytes) * 100, 1)
                    : 0,
            ],
            'disk'    => $latest->disk_bytes,
            'network' => [
                'rx' => $latest->network_rx_bytes,
                'tx' => $latest->network_tx_bytes,
            ],
            'recorded_at' => $latest->recorded_at,
        ]);
    }

    public function globalStats(): JsonResponse
    {
        return response()->json([
            'total_servers'  => Server::count(),
            'online_servers' => Server::where('status', 'online')->count(),
            'total_users'    => \App\Models\User::count(),
        ]);
    }
}
