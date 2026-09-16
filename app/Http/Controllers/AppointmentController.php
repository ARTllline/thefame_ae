<?php

namespace App\Http\Controllers;

use App\Events\AppointmentCreated;
use App\Models\Appointment;
use App\Models\User;
use App\Services\AppointmentNotificationSettings;
use Illuminate\Http\Request;

class AppointmentController extends Controller
{
    public function checkout(Request $request)
    {
        $validatedData = $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'required|string|max:30',
            'email' => 'nullable|email|max:255',
            'goal' => 'required|string|max:255',
            'region' => 'nullable|string|max:255',
            'from_page' => 'nullable|string|max:255',

            // UTM
            'utm_source' => 'nullable|string|max:255',
            'utm_medium' => 'nullable|string|max:255',
            'utm_campaign' => 'nullable|string|max:255',
            'utm_term' => 'nullable|string|max:255',
            'utm_content' => 'nullable|string|max:255',

            'referrer' => 'nullable|string|max:1000',
        ]);

        $appointment = Appointment::create($validatedData);
        AppointmentCreated::dispatch($appointment);

        return response()->json([
            'success' => true,
            'message' => 'Заявка успішно відправлена',
            'appointment_id' => $appointment->id,
        ]);
    }

    public function store(Request $request)
    {
        // Валидация входящих данных
        $validatedData = $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'required|string|max:30',
            'region' => 'nullable|string|max:255',
            'treatment' => 'nullable|string|max:1000',
            'from_page' => 'nullable|string|max:255',
            // UTM-поля
            'utm_source' => 'nullable|string|max:255',
            'utm_medium' => 'nullable|string|max:255',
            'utm_campaign' => 'nullable|string|max:255',
            'utm_term' => 'nullable|string|max:255',
            'utm_content' => 'nullable|string|max:255',

            'referrer' => 'nullable|string|max:1000',
        ]);

        $appointment = Appointment::create($validatedData);
        AppointmentCreated::dispatch($appointment);

        // Можно вернуть JSON-ответ (при AJAX-запросе)
        return response()->json([
            'success' => true,
            'message' => 'Ваша заявка успешно отправлена!',
            'appointment_id' => $appointment->id,
        ]);
    }

    public function getUserRegions(Request $request, AppointmentNotificationSettings $settings)
    {
        $data = $request->validate([
            'telegram_id' => 'required|numeric',
        ]);

        $user = User::where('telegram_id', $data['telegram_id'])->first();
        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'Пользователь не найден',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'statuses' => $settings->telegramStatus($user->telegram_id),
        ]);
    }

    public function changeUserRegion(Request $request, AppointmentNotificationSettings $settings)
    {
        $data = $request->validate([
            'telegram_id' => 'required|numeric',
            'region' => 'required|string|in:dubai,ua',
        ]);

        $user = User::where('telegram_id', $data['telegram_id'])->first();
        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'Пользователь не найден',
            ], 404);
        }

        return response()->json([
            'success' => false,
            'message' => 'Подписками теперь управляет администратор сайта.',
            'statuses' => $settings->telegramStatus($user->telegram_id),
        ], 409);
    }
}
