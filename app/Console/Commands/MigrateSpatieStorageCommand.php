<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\File;

class MigrateSpatieStorageCommand extends Command
{
    protected $signature = 'media:import-spatie-storage';
    protected $description = 'Перенос медиа из другой структуры Spatie Media Library в текущую';

    public function handle()
    {
        $this->info('Старт переноса из старого стораджа...');

        // === НАСТРОЙКИ ===
        // Путь к старому стораджу (откуда берем)
        $sourcePath = 'C:/OSPanel/domains/thefame/storage/app/public/galleries';

        // Куда кладем в текущем проекте
        $targetFolder = public_path('storage/galleries');

        // К какой модели привязываем перенесенные фото
        $targetModelType = 'App\Models\Gallery';
        $targetModelId = 1; // Замени на нужный ID галереи, если нужно
        $collectionName = 'gallery';
        $disk = 'galleries';
        // =================

        if (!File::isDirectory($sourcePath)) {
            $this->error("Папка источника не найдена: {$sourcePath}");
            return Command::FAILURE;
        }

        // Получаем все папки (которые раньше были айдишниками) внутри источника
        $directories = File::directories($sourcePath);

        foreach ($directories as $dir) {
            // Ищем оригинальный файл (он лежит прямо в папке ID)
            $filesInDir = File::files($dir);
            if (count($filesInDir) === 0) {
                continue; // Пустая папка, пропускаем
            }

            // Берем первый попавшийся файл (Spatie обычно хранит один оригинал в корне)
            $originalFile = $filesInDir[0];
            $fileNameWithExt = $originalFile->getFilename();
            $fileNameOnly = pathinfo($fileNameWithExt, PATHINFO_FILENAME);

            // Ищем папку conversions и webp файл внутри
            $conversionsDir = $dir . '/conversions';
            $webpFile = null;

            if (File::isDirectory($conversionsDir)) {
                $conversionFiles = File::files($conversionsDir);
                foreach ($conversionFiles as $cFile) {
                    if ($cFile->getExtension() === 'webp') {
                        $webpFile = $cFile;
                        break;
                    }
                }
            }

            if (!$webpFile) {
                $this->warn("Для файла {$fileNameWithExt} (в папке " . basename($dir) . ") не найдена webp конвертация. Пропускаем.");
                continue;
            }

            // --- Работа с БД (вычисляем новые ID и Order) ---
            $maxOrder = DB::table('media')
                ->where('model_type', $targetModelType)
                ->where('model_id', $targetModelId)
                ->where('collection_name', $collectionName)
                ->max('order_column') ?? 0;
            $nextOrder = $maxOrder + 1;

            $maxId = DB::table('media')->max('id') ?? 0;
            $nextId = $maxId + 1;

            $uuid = (string) Str::uuid();

            // Создаем новую запись в БД
            DB::table('media')->insert([
                'id' => $nextId,
                'model_type' => $targetModelType,
                'model_id' => $targetModelId,
                'uuid' => $uuid,
                'collection_name' => $collectionName,
                'name' => $fileNameOnly,
                'file_name' => $fileNameWithExt,
                'mime_type' => File::mimeType($originalFile->getRealPath()),
                'disk' => $disk,
                'conversions_disk' => $disk,
                'size' => $originalFile->getSize(),
                'manipulations' => json_encode([]),
                'custom_properties' => json_encode([]),
                'generated_conversions' => json_encode(['webp' => true]),
                'responsive_images' => json_encode([]),
                'order_column' => $nextOrder,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // --- Работа с файлами ---
            $mediaTargetDir = $targetFolder . '/' . $nextId;
            $conversionTargetDir = $mediaTargetDir . '/conversions';

            // Создаем новые папки по новому ID
            File::ensureDirectoryExists($mediaTargetDir);
            File::ensureDirectoryExists($conversionTargetDir);

            // Копируем оригинал и webp в новый сторадж
            File::copy($originalFile->getRealPath(), $mediaTargetDir . '/' . $fileNameWithExt);
            File::copy($webpFile->getRealPath(), $conversionTargetDir . '/' . $webpFile->getFilename());

            $this->line(" + Перенесено: {$fileNameWithExt} (Старая папка: " . basename($dir) . " -> Новый ID: {$nextId})");
        }

        $this->info('Перенос успешно завершен!');
        return Command::SUCCESS;
    }
}
