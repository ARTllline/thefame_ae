<?php

// app/Http/Controllers/LanguageController.php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;

class LanguageController extends Controller
{
    public function switchLanguage(Request $request)
    {
        // Список разрешённых языков
        $availableLocales = ['ru', 'uk', 'en'];

        $locale = $request->input('locale');

        // Если выбран язык недопустимый — используем язык по умолчанию
        if (!in_array($locale, $availableLocales)) {
            $locale = config('app.fallback_locale');
        }

        // Сохраняем выбранный язык в сессию
        session(['locale' => $locale]);

        // Применяем язык в текущем запросе
        App::setLocale($locale);

        // Перенаправляем пользователя обратно на указанный URL
        $redirectTo = $request->input('redirect_to', url('/'));


        return redirect($redirectTo);
    }
}
