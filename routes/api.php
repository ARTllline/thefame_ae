<?php

use App\Http\Controllers\CartController;
use App\Http\Controllers\OrderController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/


Route::get('products', [\App\Http\Controllers\ProductController::class, 'getProducts']);

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/store-user', [\App\Http\Controllers\AuthController::class, 'storeUser']);

    Route::get('/user/regions', [\App\Http\Controllers\AppointmentController::class, 'getUserRegions']);
    Route::post('/user/change-region', [\App\Http\Controllers\AppointmentController::class, 'changeUserRegion']);
});

Route::middleware(['web'])->prefix('cart')->group(function () {
    Route::get('/', [CartController::class, 'get']);
    Route::post('add', [CartController::class, 'add']);
    Route::post('update', [CartController::class, 'update']);
    Route::delete('remove/{id}', [CartController::class, 'remove']);
    Route::post('clear', [CartController::class, 'clear']);
});

Route::apiResource('orders', OrderController::class)->only(['index', 'show', 'store', 'update', 'destroy']);
Route::post('orders/{order}/status', [OrderController::class, 'updateStatus']);

