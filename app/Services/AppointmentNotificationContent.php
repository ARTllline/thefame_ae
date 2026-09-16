<?php

namespace App\Services;

use App\Models\Appointment;

class AppointmentNotificationContent
{
    public function __construct(private Appointment $appointment) {}

    public function title(): string
    {
        return $this->appointment->goal
            ? 'Нова заявка з посадкової сторінки'
            : 'Нова заявка';
    }

    /**
     * @return array<int, array{label: string, value: string}>
     */
    public function rows(): array
    {
        $rows = [
            ['label' => 'Номер заявки', 'value' => (string) $this->appointment->getKey()],
            ['label' => 'Дата', 'value' => $this->appointment->created_at?->format('d.m.Y H:i') ?? '—'],
            ['label' => 'Регіон', 'value' => $this->appointment->region ?: '—'],
            ['label' => 'Імʼя', 'value' => $this->appointment->name ?: '—'],
            ['label' => 'Телефон', 'value' => $this->appointment->phone ?: '—'],
        ];

        $optionalFields = [
            'email' => 'Email',
            'goal' => 'Ціль',
            'treatment' => 'Процедура',
            'from_page' => 'Сторінка',
            'utm_source' => 'UTM source',
            'utm_medium' => 'UTM medium',
            'utm_campaign' => 'UTM campaign',
            'utm_term' => 'UTM term',
            'utm_content' => 'UTM content',
            'referrer' => 'Referrer',
        ];

        foreach ($optionalFields as $attribute => $label) {
            $value = $this->appointment->getAttribute($attribute);

            if ($value !== null && $value !== '') {
                $rows[] = ['label' => $label, 'value' => (string) $value];
            }
        }

        return $rows;
    }

    public function toTelegramHtml(): string
    {
        $lines = ['<b>'.$this->escape($this->title()).'</b>', ''];

        foreach ($this->rows() as $row) {
            $lines[] = '<b>'.$this->escape($row['label']).':</b> '.$this->escape($row['value']);
        }

        return implode("\n", $lines);
    }

    private function escape(string $value): string
    {
        return htmlspecialchars($value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    }
}
