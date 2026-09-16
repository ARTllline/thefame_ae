<?php

namespace App\Nova;

use App\Services\AppointmentNotificationSettings;
use Illuminate\Http\Request;
use Laravel\Nova\Fields\Boolean;
use Laravel\Nova\Fields\Heading;
use Laravel\Nova\Fields\ID;
use Laravel\Nova\Fields\KeyValue;
use Laravel\Nova\Fields\MultiSelect;
use Laravel\Nova\Fields\Text;
use Laravel\Nova\Fields\Textarea;
use Laravel\Nova\Http\Requests\NovaRequest;
use Laravel\Nova\Panel;

class AppointmentNotificationSetting extends Resource
{
    public static $model = \App\Models\SiteSetting::class;

    public static $title = 'key';

    public static $search = [];

    public static function label(): string
    {
        return 'Настройки уведомлений';
    }

    public static function singularLabel(): string
    {
        return 'Уведомления о заявках';
    }

    public static function indexQuery(NovaRequest $request, $query)
    {
        return $query->where('key', AppointmentNotificationSettings::KEY);
    }

    public static function detailQuery(NovaRequest $request, $query)
    {
        return $query->where('key', AppointmentNotificationSettings::KEY);
    }

    public function fields(NovaRequest $request): array
    {
        return [
            ID::make()->sortable(),

            Text::make('Раздел', fn () => 'Уведомления о заявках')->exceptOnForms(),

            Heading::make('Email'),

            Boolean::make('Отправлять заявки на Email', 'email_enabled', function ($value, $resource) {
                return (bool) (self::config($resource)['email_enabled'] ?? true);
            })->fillUsing(function ($request, $model, $attribute, $requestAttribute) {
                self::put($model, 'email_enabled', $request->boolean($requestAttribute));
            }),

            KeyValue::make('Получатели Email', 'email_recipients', function ($value, $resource) {
                return self::config($resource)['email_recipients'] ?? [];
            })
                ->keyLabel('Название')
                ->valueLabel('Email')
                ->actionText('Добавить получателя')
                ->rules('json', function ($attribute, $value, $fail) {
                    foreach (array_values(json_decode((string) $value, true) ?: []) as $email) {
                        if (filter_var($email, FILTER_VALIDATE_EMAIL) === false) {
                            $fail("Некорректный Email: {$email}");
                        }
                    }
                })
                ->fillUsing(function ($request, $model, $attribute, $requestAttribute) {
                    self::put($model, 'email_recipients', json_decode($request->input($requestAttribute, '{}'), true) ?: []);
                }),

            Heading::make('Telegram'),

            Boolean::make('Отправлять заявки в Telegram', 'telegram_enabled', function ($value, $resource) {
                return (bool) (self::config($resource)['telegram_enabled'] ?? true);
            })->fillUsing(function ($request, $model, $attribute, $requestAttribute) {
                self::put($model, 'telegram_enabled', $request->boolean($requestAttribute));
            }),

            Text::make('Как добавить личный профиль', fn () => 'Пользователь должен один раз нажать /start в боте. После этого его можно выбрать по @логину ниже.')
                ->onlyOnDetail(),

            self::telegramRecipientsPanel(),
        ];
    }

    public static function authorizedToCreate(Request $request): bool
    {
        return false;
    }

    public function authorizedToDelete(Request $request): bool
    {
        return false;
    }

    public function authorizedToReplicate(Request $request): bool
    {
        return false;
    }

    /** @return array<string, mixed> */
    private static function config($model): array
    {
        $decoded = json_decode((string) $model->value, true);

        return is_array($decoded) ? $decoded : [];
    }

    private static function put($model, string $key, mixed $value): void
    {
        $config = self::config($model);
        $config[$key] = $value;
        $model->value = json_encode($config, JSON_UNESCAPED_UNICODE);
    }

    private static function telegramRecipientsPanel(): Panel
    {
        return Panel::make('Получатели Telegram этого сайта', [
            MultiSelect::make('Telegram-профили', 'telegram_profiles', function ($value, $resource) {
                return self::localTelegramValues($resource, 'telegram_profile_ids');
            })
                ->options(fn () => self::telegramProfileOptions())
                ->displayUsingLabels()
                ->rules('json', function ($attribute, $value, $fail) {
                    $ids = collect(json_decode((string) $value, true) ?: [])->map(fn ($id) => (int) $id)->filter();

                    if (\App\Models\User::query()
                        ->whereIn('id', $ids)
                        ->whereNotNull('telegram_id')
                        ->where('telegram_id', '!=', 0)
                        ->count() !== $ids->unique()->count()) {
                        $fail('Один из выбранных Telegram-профилей больше не существует.');
                    }
                })
                ->fillUsing(function ($request, $model, $attribute, $requestAttribute) {
                    $profileIds = collect(json_decode($request->input($requestAttribute, '[]'), true) ?: [])
                        ->map(fn ($id) => (int) $id)
                        ->filter()
                        ->unique()
                        ->values()
                        ->all();

                    self::putTelegram($model, 'telegram_profile_ids', $profileIds);
                })
                ->help('Список формируется из пользователей, которые запускали Telegram-бота этого сайта.'),

            Textarea::make('Chat ID / @каналы', 'telegram_direct_recipients', function ($value, $resource) {
                return implode("\n", self::localTelegramValues($resource, 'telegram_direct_recipients'));
            })
                ->alwaysShow()
                ->rules('nullable', function ($attribute, $value, $fail) {
                    foreach (self::recipientLines((string) $value) as $identifier) {
                        if (! preg_match('/^-?\d+$|^@[A-Za-z0-9_]{5,}$/', $identifier)) {
                            $fail("Некорректный Telegram-получатель: {$identifier}");
                        }
                    }
                })
                ->fillUsing(function ($request, $model, $attribute, $requestAttribute) {
                    self::putTelegram(
                        $model,
                        'telegram_direct_recipients',
                        self::recipientLines((string) $request->input($requestAttribute, '')),
                    );
                })
                ->help('По одному значению на строку. Для личного аккаунта используйте числовой chat ID; @username здесь предназначен прежде всего для каналов и супергрупп.'),
        ]);
    }

    /** @return array<int, string> */
    private static function telegramProfileOptions(): array
    {
        return \App\Models\User::query()
            ->whereNotNull('telegram_id')
            ->where('telegram_id', '!=', 0)
            ->orderBy('telegram_name')
            ->get(['id', 'telegram_id', 'telegram_login', 'telegram_name'])
            ->mapWithKeys(function ($user) {
                $login = $user->telegram_login ? '@'.ltrim($user->telegram_login, '@') : 'без @логина';
                $name = $user->telegram_name ?: 'без имени';

                return [$user->id => "{$login} — {$name} — ID {$user->telegram_id}"];
            })
            ->all();
    }

    /** @return array<int, string> */
    private static function recipientLines(string $value): array
    {
        return collect(preg_split('/\r\n|\r|\n/', $value) ?: [])
            ->map(fn ($line) => trim($line))
            ->filter()
            ->unique()
            ->values()
            ->all();
    }

    private static function putTelegram($model, string $key, mixed $value): void
    {
        $config = self::config($model);
        $config[$key] = $value;
        $config['telegram_recipients_migrated'] = true;
        $model->value = json_encode($config, JSON_UNESCAPED_UNICODE);
    }

    /** @return array<int, mixed> */
    private static function localTelegramValues($model, string $key): array
    {
        $values = self::config($model)[$key] ?? [];

        if (! is_array($values)) {
            return [];
        }

        if (array_is_list($values)) {
            return array_values($values);
        }

        return collect(['all', 'dubai'])
            ->flatMap(fn ($scope) => is_array($values[$scope] ?? null) ? $values[$scope] : [])
            ->unique()
            ->values()
            ->all();
    }
}
