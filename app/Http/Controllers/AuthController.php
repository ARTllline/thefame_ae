<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Services\AppointmentNotificationSettings;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    /**
     * Регистрирует пользователя для подписки на уведомления заявок сайта TheFame.
     *
     * Принимает данные от Telegram-бота:
     * - telegram_id: ID пользователя в Telegram.
     * - first_name: Имя пользователя.
     * - last_name: (опционально) Фамилия пользователя.
     * - username: (опционально) Логин пользователя в Telegram.
     *
     * Если пользователь с таким telegram_id уже зарегистрирован,
     * возвращается сообщение об этом с уже существующими данными пользователя.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function storeUser(Request $request, AppointmentNotificationSettings $settings)
    {
        // Валидация входящих данных
        $validatedData = $request->validate([
            'telegram_id' => 'required|numeric',
            'first_name' => 'nullable|string|max:255',
            'last_name' => 'nullable|string|max:255',
            'username' => 'nullable|string|max:255',
        ]);

        // Формируем имя пользователя из first_name и last_name
        $name = $validatedData['first_name'] ?? null;
        if (! empty($validatedData['last_name'])) {
            $name .= ' '.$validatedData['last_name'];
        }
        $name = trim($name ?: ($validatedData['username'] ?? 'Telegram '.$validatedData['telegram_id']));

        $user = User::firstOrNew(['telegram_id' => $validatedData['telegram_id']]);
        $created = ! $user->exists;

        $user->fill([
            'name' => $name,
            'telegram_login' => isset($validatedData['username'])
                ? ltrim($validatedData['username'], '@')
                : null,
            'telegram_name' => $name,
        ]);

        if ($created) {
            $user->email = "telegram_{$validatedData['telegram_id']}@telegram.local";
            $user->password = Hash::make(Str::random(64));
        }

        $user->save();

        return response()->json([
            'success' => true,
            'message' => $created ? 'Telegram-профиль зарегистрирован' : 'Telegram-профиль обновлён',
            'profile' => [
                'telegram_id' => (string) $user->telegram_id,
                'username' => $user->telegram_login,
                'name' => $user->telegram_name,
            ],
            'statuses' => $settings->telegramStatus($user->telegram_id),
        ], $created ? 201 : 200);
    }
}
