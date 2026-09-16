<?php

namespace App\Services;

use App\Models\SiteSetting;
use App\Models\User;
use Illuminate\Support\Facades\Log;

class AppointmentNotificationSettings
{
    public const KEY = 'appointment_notifications';

    public function emailEnabled(): bool
    {
        return (bool) ($this->values()['email_enabled'] ?? true);
    }

    /** @return array<int, string> */
    public function emailRecipients(): array
    {
        $recipients = $this->values()['email_recipients'] ?? [];

        return collect(is_array($recipients) ? array_values($recipients) : [])
            ->map(fn ($email) => trim((string) $email))
            ->filter(fn ($email) => filter_var($email, FILTER_VALIDATE_EMAIL) !== false)
            ->unique()
            ->values()
            ->all();
    }

    public function telegramEnabled(): bool
    {
        return (bool) ($this->values()['telegram_enabled'] ?? true);
    }

    /** @return array<int, string> */
    public function telegramRecipients(): array
    {
        $values = $this->values();

        if (! ($values['telegram_recipients_migrated'] ?? false)) {
            return $this->legacyTelegramRecipients();
        }

        $profileIds = collect($this->localTelegramValues($values['telegram_profile_ids'] ?? []))
            ->map(fn ($id) => (int) $id)
            ->filter()
            ->unique()
            ->values();

        $profileChatIds = User::query()
            ->whereIn('id', $profileIds)
            ->whereNotNull('telegram_id')
            ->pluck('telegram_id')
            ->map(fn ($chatId) => (string) $chatId);

        $directRecipients = collect($this->localTelegramValues($values['telegram_direct_recipients'] ?? []))
            ->map(fn ($identifier) => $this->resolveDirectRecipient((string) $identifier))
            ->filter();

        return $profileChatIds
            ->merge($directRecipients)
            ->filter(fn ($chatId) => $chatId !== '0')
            ->unique()
            ->values()
            ->all();
    }

    /** @return array{enabled: bool} */
    public function telegramStatus(string|int $chatId): array
    {
        $chatId = (string) $chatId;
        $enabled = in_array($chatId, $this->telegramRecipients(), true);
        return [
            'enabled' => $enabled,
        ];
    }

    /** @return array<int, string> */
    private function legacyTelegramRecipients(): array
    {
        return User::query()
            ->where('is_appointment_dubai', true)
            ->whereNotNull('telegram_id')
            ->pluck('telegram_id')
            ->map(fn ($chatId) => (string) $chatId)
            ->unique()
            ->values()
            ->all();
    }

    private function resolveDirectRecipient(string $identifier): ?string
    {
        $identifier = trim($identifier);

        if (preg_match('/^-?\d+$/', $identifier)) {
            return $identifier;
        }

        if (! preg_match('/^@[A-Za-z0-9_]{5,}$/', $identifier)) {
            return null;
        }

        $profileChatId = User::query()
            ->whereRaw('LOWER(telegram_login) = ?', [mb_strtolower(ltrim($identifier, '@'))])
            ->value('telegram_id');

        return $profileChatId ? (string) $profileChatId : $identifier;
    }

    /** @return array<string, mixed> */
    private function values(): array
    {
        try {
            $value = SiteSetting::query()->where('key', self::KEY)->value('value');
            $decoded = is_string($value) ? json_decode($value, true) : null;

            if (is_array($decoded)) {
                return $decoded;
            }
        } catch (\Throwable $exception) {
            Log::error('Unable to read appointment notification settings.', [
                'exception' => $exception,
            ]);
        }

        return config('notifications.appointments.defaults', []);
    }

    /** @return array<int, mixed> */
    private function localTelegramValues(mixed $values): array
    {
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
