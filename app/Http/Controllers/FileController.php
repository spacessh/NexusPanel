<?php

namespace App\Http\Controllers;

use App\Models\Server;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use League\Flysystem\Filesystem;
use League\Flysystem\PhpseclibV3\SftpConnectionProvider;
use League\Flysystem\PhpseclibV3\SftpAdapter;

class FileController extends Controller
{
    public function list(Request $request, Server $server): JsonResponse
    {
        $path = $request->get('path', '/');

        // In production: connect to Wings API for file listing
        // For now return mock structure
        $files = [
            ['name' => 'config',     'type' => 'directory', 'size' => 0,        'modified' => now()->toISOString()],
            ['name' => 'plugins',    'type' => 'directory', 'size' => 0,        'modified' => now()->toISOString()],
            ['name' => 'server.jar', 'type' => 'file',      'size' => 52428800, 'modified' => now()->toISOString()],
            ['name' => 'eula.txt',   'type' => 'file',      'size' => 128,      'modified' => now()->toISOString()],
        ];

        return response()->json(['path' => $path, 'files' => $files]);
    }

    public function contents(Request $request, Server $server): JsonResponse
    {
        $path = $request->validate(['path' => 'required|string'])['path'];

        // TODO: Fetch from Wings daemon
        return response()->json(['content' => '# Server config file', 'encoding' => 'utf-8']);
    }

    public function write(Request $request, Server $server): JsonResponse
    {
        $data = $request->validate([
            'path'    => 'required|string',
            'content' => 'required|string',
        ]);

        // TODO: Write via Wings daemon
        return response()->json(['success' => true]);
    }

    public function delete(Request $request, Server $server): JsonResponse
    {
        $data = $request->validate(['paths' => 'required|array']);

        // TODO: Delete via Wings daemon
        return response()->json(['success' => true]);
    }

    public function rename(Request $request, Server $server): JsonResponse
    {
        $data = $request->validate([
            'from' => 'required|string',
            'to'   => 'required|string',
        ]);

        // TODO: Rename via Wings daemon
        return response()->json(['success' => true]);
    }
}
