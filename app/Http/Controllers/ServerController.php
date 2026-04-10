<?php

namespace App\Http\Controllers;

use App\Models\Server;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Str;

class ServerController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $servers = Server::with(['node', 'user'])
            ->when($request->search, fn($q, $s) => $q->where('name', 'like', "%{$s}%"))
            ->when($request->status, fn($q, $s) => $q->where('status', $s))
            ->paginate(20);

        return response()->json($servers);
    }

    public function show(Server $server): JsonResponse
    {
        return response()->json($server->load(['node', 'user', 'backups']));
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name'            => 'required|string|max:191',
            'user_id'         => 'required|exists:users,id',
            'node_id'         => 'required|exists:nodes,id',
            'game_type'       => 'required|string',
            'memory'          => 'required|integer|min:128',
            'disk'            => 'required|integer|min:1024',
            'cpu'             => 'required|integer|min:0',
            'port'            => 'required|integer|between:1024,65535',
            'startup_command' => 'required|string',
        ]);

        $server = Server::create([
            ...$validated,
            'uuid'   => Str::uuid(),
            'status' => Server::STATUS_OFFLINE,
        ]);

        return response()->json($server, 201);
    }

    public function power(Request $request, Server $server): JsonResponse
    {
        $action = $request->validate(['action' => 'required|in:start,stop,restart,kill'])['action'];

        $statusMap = [
            'start'   => Server::STATUS_STARTING,
            'stop'    => Server::STATUS_STOPPING,
            'restart' => Server::STATUS_STARTING,
            'kill'    => Server::STATUS_OFFLINE,
        ];

        $server->update(['status' => $statusMap[$action]]);

        // TODO: Forward to Wings daemon
        // $this->wingsService->sendPowerAction($server, $action);

        return response()->json(['status' => $server->status]);
    }

    public function destroy(Server $server): JsonResponse
    {
        $server->delete();
        return response()->json(null, 204);
    }
}
