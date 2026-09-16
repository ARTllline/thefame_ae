<?php

use App\Http\Controllers\AppointmentController;
use App\Http\Controllers\RouteController;
use Illuminate\Support\Facades\Route;

Route::controller(RouteController::class)->group(function () {
    Route::get('/', 'showHome')->name('home');
    Route::get('/services/{service}', 'showService')->name('service');
});

Route::prefix('{locale}')
    ->where(['locale' => 'ru|ua|en'])
    ->name('localized.')
    ->controller(RouteController::class)
    ->group(function () {
        Route::get('/', 'showHome')->name('home');
        Route::get('/services/{service}', 'showLocalizedService')->name('service');
});

Route::post('/appointment', [AppointmentController::class, 'store'])->name('appointments.store');
Route::post('/checkout', [AppointmentController::class, 'checkout'])->name('checkout.promo');


Route::get('/info', function () {
    return [
        'upload_max_filesize' => ini_get('upload_max_filesize'),
        'post_max_size' => ini_get('post_max_size'),
    ];
});
