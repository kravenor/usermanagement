<?php

use Illuminate\Support\Facades\Route;


Route::prefix('roles')->group(function () {
    Route::get('/', [\App\Http\Controllers\RolesController::class, 'index']);
    Route::post('save', [\App\Http\Controllers\RolesController::class, 'store']);
    Route::put('update', [\App\Http\Controllers\RolesController::class, 'update']);
    Route::post('show', [\App\Http\Controllers\RolesController::class, 'show']);
    Route::delete("delete", [\App\Http\Controllers\RolesController::class, 'destroy']);

    Route::post("assign", [\App\Http\Controllers\RolesController::class, 'assignRole']);
    Route::post("deassign", [\App\Http\Controllers\RolesController::class, 'deassignRole']);
})->middleware('auth:api');

Route::prefix('users')->group(function () {
    Route::get('all', [\App\Http\Controllers\UserController::class, 'getAll']);
    Route::get('/', [\App\Http\Controllers\UserController::class, 'index']);
    Route::post('save', [\App\Http\Controllers\UserController::class, 'store']);
    Route::post('show', [\App\Http\Controllers\UserController::class, 'show']);
    Route::put('update', [\App\Http\Controllers\UserController::class, 'update']);
    Route::delete('delete', [\App\Http\Controllers\UserController::class, 'destroy']);
    Route::delete('delete-multiple', [\App\Http\Controllers\UserController::class, 'destroyMultiple']);
})->middleware('auth:api');


Route::prefix('auth')->group(function () {
    Route::post('login', [\App\Http\Controllers\LoginController::class, 'authenticate']);
    Route::post('logout', [\App\Http\Controllers\LoginController::class, 'logout'])->middleware('auth:api');
    Route::post('refresh', [\App\Http\Controllers\LoginController::class, 'refresh'])->middleware('auth:api');
    Route::post('me', [\App\Http\Controllers\LoginController::class, 'me']);
});
