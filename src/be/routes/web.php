<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response(null, 500);
})->name('home');
