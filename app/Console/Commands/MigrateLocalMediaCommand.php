<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\File;

class MigrateLocalMediaCommand extends Command
{
    protected $signature = 'media:force-import';
    protected $description = 'Автоматический импорт всех фото из папок к заданным моделям';

    public function handle()
    {
        $this->info('Старт массового импорта медиафайлов...');

        // Базовые пути к папкам с новыми фото
        $sourceAboutOri = 'B:/fame_gallery/about';
        $sourceAboutWebp = 'B:/fame_gallery/about_webp';

        $sourceGallOri = 'B:/fame_gallery/gall';
        $sourceGallWebp = 'B:/fame_gallery/gall_webp';

        // Папки назначения в Laravel
        $storagePublic = public_path('storage');

        // 1. Импорт всех фото для ABOUT (привязываем к ID = 1, коллекция main-dubai)
        if (File::exists($sourceAboutOri)) {
            $this->info("Обработка папки About...");
            $this->processFolder(
                $sourceAboutOri,
                $sourceAboutWebp,
                1,                    // <--- Все файлы идут к модели с ID 1
                'App\Models\About',   // Тип модели
                'main-dubai',         // Коллекция
                'abouts',             // Диск
                $storagePublic . '/abouts'
            );
        } else {
            $this->warn("Папка {$sourceAboutOri} не найдена.");
        }

        // 2. Импорт всех фото для GALLERY (привязываем к ID = 1, коллекция gallery)
        if (File::exists($sourceGallOri)) {
            $this->info("Обработка папки Gallery...");
            $this->processFolder(
                $sourceGallOri,
                $sourceGallWebp,
                1,                    // <--- Все файлы идут к модели с ID 1
                'App\Models\Gallery', // Тип модели
                'gallery',            // Коллекция
                'galleries',          // Диск
                $storagePublic . '/galleries'
            );
        } else {
            $this->warn("Папка {$sourceGallOri} не найдена.");
        }

        $this->info('Импорт успешно завершен!');
        return Command::SUCCESS;
    }

    protected function processFolder($oriPath, $webpPath, $modelId, $modelType, $collectionName, $disk, $targetFolder)
    {
        $files = \Illuminate\Support\Facades\File::files($oriPath);

        foreach ($files as $file) {
            $fileNameWithExt = $file->getFilename();
            $fileNameOnly = pathinfo($fileNameWithExt, PATHINFO_FILENAME);

            // Ищем webp аналог
            $webpFile = $webpPath . '/' . $fileNameOnly . '-webp.webp';
            if (!\Illuminate\Support\Facades\File::exists($webpFile)) {
                $webpFile = $webpPath . '/' . $fileNameOnly . '.webp';
                if (!\Illuminate\Support\Facades\File::exists($webpFile)) {
                    $this->error("Для файла {$fileNameWithExt} не найден .webp эквивалент. Пропускаем.");
                    continue;
                }
            }

            // Находим максимальный order_column
            $maxOrder = \Illuminate\Support\Facades\DB::table('media')
                ->where('model_type', $modelType)
                ->where('model_id', $modelId)
                ->where('collection_name', $collectionName)
                ->max('order_column') ?? 0;
            $nextOrder = $maxOrder + 1;

            // === ВАЖНО: ВРУЧНУЮ СЧИТАЕМ СЛЕДУЮЩИЙ ID ===
            $maxId = \Illuminate\Support\Facades\DB::table('media')->max('id') ?? 0;
            $nextId = $maxId + 1;

            $uuid = (string) \Illuminate\Support\Str::uuid();

            // Жестко записываем сгенерированный ID
            \Illuminate\Support\Facades\DB::table('media')->insert([
                'id' => $nextId,
                'model_type' => $modelType,
                'model_id' => $modelId,
                'uuid' => $uuid,
                'collection_name' => $collectionName,
                'name' => $fileNameOnly,
                'file_name' => $fileNameWithExt,
                'mime_type' => \Illuminate\Support\Facades\File::mimeType($file->getRealPath()),
                'disk' => $disk,
                'conversions_disk' => $disk,
                'size' => $file->getSize(),
                'manipulations' => json_encode([]),
                'custom_properties' => json_encode([]),
                'generated_conversions' => json_encode(['webp' => true]),
                'responsive_images' => json_encode([]),
                'order_column' => $nextOrder,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Создаем папки на основе нашего вычисленного ID
            $mediaTargetDir = $targetFolder . '/' . $nextId;
            $conversionTargetDir = $mediaTargetDir . '/conversions';

            \Illuminate\Support\Facades\File::ensureDirectoryExists($mediaTargetDir);
            \Illuminate\Support\Facades\File::ensureDirectoryExists($conversionTargetDir);

            // Копируем файлы
            \Illuminate\Support\Facades\File::copy($file->getRealPath(), $mediaTargetDir . '/' . $fileNameWithExt);
            \Illuminate\Support\Facades\File::copy($webpFile, $conversionTargetDir . '/' . $fileNameOnly . '-webp.webp');

            $this->line(" + Загружено: {$fileNameWithExt} (Сгенерирован ID: {$nextId})");
        }
    }
}
