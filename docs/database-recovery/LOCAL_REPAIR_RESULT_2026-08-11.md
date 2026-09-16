# TheFame AE: результат безопасного локального ремонта БД

Дата: 2026-08-11.

## Что было сделано

- Исходная локальная копия `thefame_ae` оставлена без изменений.
- До любых исправлений создан полный SQL backup структуры и данных.
- Для ремонта создана отдельная база `thefame_ae_repaired`.
- Без удаления строк восстановлены типы колонок, nullable/default, primary keys,
  `AUTO_INCREMENT`, обычные и unique-индексы, charset/collation и все безопасные
  foreign keys.
- Запущены все 8 актуальных AE migrations; pending migrations отсутствуют.
- Финальный дамп повторно импортирован в отдельную временную базу и заново
  проверен schema-аудитором.

Исходный backup:

`C:\OSPanel\userdata\backups\thefame_ae\thefame_ae_before_repair_20260811_175528.sql`

SHA-256: `D9473FEE6ADB119BF57029BCEF85F59BE9337BA8ABDDDD02F8A5038A61D76AA5`

Готовый дамп для импорта в новую пустую cPanel-БД:

`C:\OSPanel\userdata\backups\thefame_ae\thefame_ae_repaired_ready_for_cpanel_20260811_180621.sql`

SHA-256: `9D08AE2708AADB73362F8FD3D4544A0AF7343FF211AB0F71BA10F7DD28EECE3C`

Размер: 2 722 185 байт. Дамп содержит 38 `CREATE TABLE` и 32 `INSERT INTO`.
В нём нет `CREATE DATABASE`, `USE` или `DEFINER`, поэтому целевую пустую базу
нужно заранее выбрать в phpMyAdmin.

## Нормализация данных

Ни одна строка не удалялась. На ремонтной копии выполнено следующее:

- 188 строкам `action_events`, 16 строкам `appointments` и 4 строкам `devices`
  с пустым `id` назначены новые уникальные ID выше прежнего `MAX(id)`;
- 8 Telegram-профилям с пустыми `email`/`password` назначены уникальные
  технические email и случайные Laravel password hashes;
- разрешён `NULL` в `users.telegram_id` для обычного Nova-пользователя;
- единичные пустые notification flags приведены к их AE defaults;
- `phone` восстановлен как строка, но уже потерянные прежним импортом `+` или
  ведущие нули невозможно восстановить без более раннего источника;
- `promo_banners.link` безопасно переведён из `latin1` в `utf8mb4`: фактическое
  значение было ASCII.

Количество строк совпадает с исходной `thefame_ae` во всех 38 таблицах. После
ремонта `appointments` содержит 391 уникальный непустой ID, `MAX(id) = 398`,
следующий `AUTO_INCREMENT = 399`.

## Намеренно не добавленные foreign keys

Итоговый schema audit показывает только 6 отличий, и все они являются
foreign keys, которые MySQL нельзя безопасно добавить при текущих данных:

| Таблица | Связь | Осиротевших строк |
|---|---|---:|
| `order_items` | `order_id -> orders.id` | 23 |
| `order_items` | `product_id -> products.id` | 23 |
| `product_ingredients` | `product_id -> products.id` | 18 |
| `product_variants` | `product_id -> products.id` | 84 |
| `service_categories` | `service_id -> services.id` | 33 |
| `service_variants` | `service_id -> services.id` | 120 |

Соответствующие обычные индексы присутствуют. Строки сохранены, поэтому
приложение может их читать, но целостность этих шести исторических связей пока
не обеспечивается самой БД. Для полного исправления нужны доверенный backup
родительских записей или подтверждённая таблица соответствия старых и новых ID.

## Проверки локальной ремонтной копии

- Laravel 10.48.29 / PHP 8.3.32 загружается, зарегистрировано 129 routes.
- Главная `/`, локализованная `/en` и `/admin/login` вернули HTTP 200.
- Auth provider находит обычного администратора; все 10 password hashes валидны.
- Все 20 текущих services имеют region; Eloquent categories/variants загружаются.
- Настройка уведомлений содержит валидный JSON: email/Telegram включены,
  выбраны 4 локальных Telegram-профиля и нет прямых hardcoded recipients.
- Транзакционный вызов настоящего `AppointmentController::store` получил HTTP
  200, ID 399 и timestamps, затем обновил запись и полностью откатился обратно
  до 391 заявок. Event был подменён, реальные email/Telegram не отправлялись.
- `php artisan test`: 21 тест, 90 assertions, все прошли.
- `npm run build`: успешно; остаются только предупреждения об устаревающем Sass
  API/`@import`.
- Round-trip импорт финального дампа: 38 таблиц, 391 appointments, 53 migrations,
  1 site setting; повторный аудит снова показал только те же 6 foreign keys.

Локально Nova license check записал SSL certificate warning из-за цепочки CA в
OSPanel. Страница Nova login при этом вернула 200. Это не schema-ошибка; на
сервере нужно отдельно проверить доступ PHP/cURL к `nova.laravel.com`.

## Безопасный перенос через cPanel/phpMyAdmin

Не импортировать финальный дамп поверх заполненной production-БД.

1. В phpMyAdmin экспортировать текущую production-БД: **Custom -> SQL**, все
   таблицы, одновременно **Structure** и **Data**. Скачать и проверить наличие
   `CREATE TABLE` и `INSERT INTO`.
2. В cPanel MySQL Databases создать новую пустую БД, например
   `account_thefame_ae_repaired`.
3. Назначить приложению DB user права на новую БД.
4. В phpMyAdmin выбрать именно новую пустую БД и импортировать готовый dump.
5. Убедиться, что импорт завершён без красных ошибок и видно 38 таблиц.
6. На время переключения включить maintenance mode, если Terminal доступен.
7. Через cPanel File Manager изменить в production `.env` только `DB_DATABASE`
   на новую БД. `DB_HOST`, user, password и остальные secrets не менять.
8. Сбросить config cache через Terminal/Cron: `php artisan config:clear`. Если
   CLI совсем недоступен, после резервной копии можно удалить только сгенерированный
   `bootstrap/cache/config.php` через File Manager; Laravel создаст его заново
   при следующем `config:cache`.
9. Проверить главную, `/admin/login`, Nova list/edit и настоящую тестовую заявку.
10. Старую production-БД не удалять минимум до завершения проверки и периода
    наблюдения.

Вместе с БД нужно развернуть актуальную локальную версию AE-кода. phpMyAdmin
переносит только базу; он не обновляет Laravel controllers, migrations, config,
frontend assets или notification flow.

## Rollback

Если после переключения есть ошибка:

1. Вернуть maintenance mode.
2. Вернуть прежнее значение `DB_DATABASE` в `.env`.
3. Снова очистить config cache.
4. Проверить, что приложение читает старую БД.
5. Новую БД не удалять: оставить для диагностики.

Если cPanel разрешает только одну БД, не заменять её дампом поверх существующих
таблиц. Нужно запросить у hosting support временную вторую БД или увеличение
лимита; это сохраняет простой и быстрый rollback.

## Production verification

- Главная и локализованные страницы отвечают 200.
- Nova login проходит с существующим обычным admin account.
- Списки services/appointments открываются, сортировка и фильтры не дают SQL errors.
- Созданная через реальную форму тестовая заявка имеет новый ID больше 398,
  непустые `created_at`/`updated_at` и видна в Nova.
- Email и Telegram дошли ожидаемым AE-получателям; при сбое сама заявка осталась
  сохранённой, а ошибка записалась в `storage/logs/laravel.log`.
- После Nova edit у заявки обновился `updated_at`.
- В Laravel log нет новых `SQLSTATE`, type conversion или constraint errors.
- Старые orders/products и шесть неполных отношений отдельно проверены до
  включения соответствующей функциональности.
