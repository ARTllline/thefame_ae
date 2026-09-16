<?php

namespace App\Services;

use App\Models\User;
use GuzzleHttp\Client;
use Illuminate\Support\Facades\Log;
use RuntimeException;

class TelegramService
{
    protected Client $client;

    protected ?string $botToken;

    protected string $baseUri;

    public function __construct()
    {
        $this->botToken = config('services.telegram.bot_token'); // из .env
        $this->baseUri = config('services.telegram.base_uri');    // 'https://api.telegram.org/bot'
        $this->client = new Client(['timeout' => 10]);
    }

    /**
     * Отправка сообщения в Telegram с опциональной inline-клавиатурой.
     *
     * @param  User  $user  Пользователь с telegram_id
     * @param  string  $text  Текст сообщения
     * @param  mixed  $keyboard  Может быть массивом или JSON-строкой
     */
    public function sendCustomMessage(User $user, string $text, $keyboard = null): bool
    {
        if (empty($user->telegram_id)) {
            return false;
        }

        try {
            $this->sendToChat((string) $user->telegram_id, $text, $keyboard);

            return true;
        } catch (\Throwable) {
            return false;
        }
    }

    /**
     * Send a message to a Telegram chat.
     *
     * Exceptions are intentionally propagated so the notification layer can
     * isolate and log the failed recipient.
     */
    public function sendToChat(string $chatId, string $text, $keyboard = null): void
    {
        if ($this->botToken === null || $this->botToken === '') {
            throw new RuntimeException('TELEGRAM_BOT_TOKEN is not configured.');
        }

        $url = $this->baseUri.$this->botToken.'/sendMessage';

        $params = [
            'chat_id' => $chatId,
            'text' => $text,
            'parse_mode' => 'HTML',
        ];

        // Если клавиатура передана, приводим её к массиву
        if (! empty($keyboard)) {
            if (is_string($keyboard)) {
                $decodedKeyboard = json_decode($keyboard, true);
            } else {
                $decodedKeyboard = $keyboard;
            }

            // Если удалось получить массив и он не пустой, преобразуем для Telegram API
            if (is_array($decodedKeyboard) && ! empty($decodedKeyboard)) {
                $params['reply_markup'] = json_encode(['inline_keyboard' => $decodedKeyboard]);
            }
        }

        try {
            // Log::info('Отправка Telegram-сообщения', ['payload' => $params]);

            $response = $this->client->post($url, [
                'form_params' => $params,
            ]);

            $result = json_decode((string) $response->getBody(), true);

            if (! isset($result['ok']) || $result['ok'] !== true) {
                throw new RuntimeException('Telegram API rejected the message.');
            }
        } catch (\Throwable $exception) {
            Log::error('Telegram message delivery failed.', [
                'chat_id' => $chatId,
                'exception_class' => $exception::class,
                'message' => $this->redactToken($exception->getMessage()),
            ]);

            throw new RuntimeException('Telegram message delivery failed.', 0, $exception);
        }
    }

    private function redactToken(string $message): string
    {
        return $this->botToken
            ? str_replace($this->botToken, '[redacted]', $message)
            : $message;
    }
}
