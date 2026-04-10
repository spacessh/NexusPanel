<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ServerController;
use App\Http\Controllers\FileController;
use App\Http\Controllers\MonitoringController;

/*
|--------------------------------------------------------------------------
| NexusPanel API Routes
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->group(function () {

    // Global stats
    Route::get('/stats', [MonitoringController::class, 'globalStats']);

    // Servers
    Route::apiResource('servers', ServerController::class);
    Route::post('/servers/{server}/power', [ServerController::class, 'power']);

    // File Manager (Pelican-style)
    Route::prefix('servers/{server}/files')->group(function () {
        Route::get('/',        [FileController::class, 'list']);
        Route::get('/content', [FileController::class, 'contents']);
        Route::post('/write',  [FileController::class, 'write']);
        Route::post('/delete', [FileController::class, 'delete']);
        Route::put('/rename',  [FileController::class, 'rename']);
    });

    // Monitoring (PhysGun-style)
    Route::prefix('servers/{server}/monitoring')->group(function () {
        Route::get('/stats',   [MonitoringController::class, 'stats']);
        Route::get('/current', [MonitoringController::class, 'current']);
    });

});

// Auth
Route::post('/auth/login',  [\App\Http\Controllers\Auth\LoginController::class, 'login']);
Route::post('/auth/logout', [\App\Http\Controllers\Auth\LoginController::class, 'logout'])->middleware('auth:sanctum');
