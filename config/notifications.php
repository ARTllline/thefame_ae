<?php

return [
    'appointments' => [
        'site_region' => env('APP_SITE_REGION', 'dubai'),
        'defaults' => [
            'email_enabled' => true,
            'email_recipients' => [
                'Основний' => 'vedutenkonikita149@gmail.com',
            ],
            'telegram_enabled' => true,
            'telegram_recipients' => [],
            'telegram_profile_ids' => [],
            'telegram_direct_recipients' => [],
            'telegram_recipients_migrated' => false,
        ],
    ],
];
