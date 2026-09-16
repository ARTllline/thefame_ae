<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

class SanitizeMediaNamesCommand extends Command
{
    protected $signature = 'media:sanitize-names';
    protected $description = 'Транслитерация и очистка имен файлов в таблице media и сторадже';

    public function handle()
    {
        $this->info('Начинаем сканирование и переименование медиафайлов...');

        $mediaItems = DB::table('media')->get();
        $updatedCount = 0;

        foreach ($mediaItems as $media) {
            $oldFileName = $media->file_name;
            $oldName = $media->name;

            // Генерируем новые чистые имена
            $newFileName = $this->sanitizeString($oldFileName);
            $newName = $this->sanitizeString($oldName);

            // Если имя уже чистое — пропускаем
            if ($oldFileName === $newFileName && $oldName === $newName) {
                continue;
            }

            // Физический путь к папке с файлом (на основе диска)
            $diskPath = storage_path('app/public/' . $media->disk . '/' . $media->id);

            $oldFilePath = $diskPath . '/' . $oldFileName;
            $newFilePath = $diskPath . '/' . $newFileName;

            // 1. Переименовываем оригинальный файл
            if (File::exists($oldFilePath)) {
                File::move($oldFilePath, $newFilePath);
                $this->line("Оригинал переименован: {$oldFileName} -> {$newFileName}");
            } else {
                $this->warn("Оригинал не найден (возможно уже переименован): {$oldFilePath}");
            }

            // 2. Переименовываем конвертации (папка conversions)
            $conversionsPath = $diskPath . '/conversions';
            if (File::isDirectory($conversionsPath)) {
                $files = File::files($conversionsPath);

                foreach ($files as $file) {
                    $cOldFilename = $file->getFilename();

                    // Spatie формирует имя так: {name}-{conversion_name}.ext
                    // Поэтому мы ищем старое имя (name) и заменяем на новое
                    if (str_starts_with($cOldFilename, $oldName)) {
                        $cNewFilename = str_replace($oldName, $newName, $cOldFilename);
                        File::move($file->getRealPath(), $conversionsPath . '/' . $cNewFilename);
                        $this->line("   Конвертация переименована: {$cOldFilename} -> {$cNewFilename}");
                    }
                }
            }

            // 3. Обновляем базу данных
            DB::table('media')->where('id', $media->id)->update([
                'name' => $newName,
                'file_name' => $newFileName,
                'updated_at' => now(),
            ]);

            $updatedCount++;
        }

        $this->info("Готово! Успешно переименовано записей: {$updatedCount}");
        return Command::SUCCESS;
    }

    /**
     * Транслитерация кириллицы в латиницу и очистка от спецсимволов.
     * Оставляет только a-z, 0-9, точки, тире и нижние подчеркивания.
     */
    protected function sanitizeString($string)
    {
        $converter = [
            'а' => 'a',   'б' => 'b',   'в' => 'v',
            'г' => 'g',   'д' => 'd',   'е' => 'e',
            'ё' => 'e',   'ж' => 'zh',  'з' => 'z',
            'и' => 'i',   'й' => 'y',   'к' => 'k',
            'л' => 'l',   'м' => 'm',   'н' => 'n',
            'о' => 'o',   'п' => 'p',   'р' => 'r',
            'с' => 's',   'т' => 't',   'у' => 'u',
            'ф' => 'f',   'х' => 'h',   'ц' => 'c',
            'ч' => 'ch',  'ш' => 'sh',  'щ' => 'sch',
            'ь' => '',    'ы' => 'y',   'ъ' => '',
            'э' => 'e',   'ю' => 'yu',  'я' => 'ya',

            'А' => 'A',   'Б' => 'B',   'В' => 'V',
            'Г' => 'G',   'Д' => 'D',   'Е' => 'E',
            'Ё' => 'E',   'Ж' => 'Zh',  'З' => 'Z',
            'И' => 'I',   'Й' => 'Y',   'К' => 'K',
            'Л' => 'L',   'М' => 'M',   'Н' => 'N',
            'О' => 'O',   'П' => 'P',   'Р' => 'R',
            'С' => 'S',   'Т' => 'T',   'У' => 'U',
            'Ф' => 'F',   'Х' => 'H',   'Ц' => 'C',
            'Ч' => 'Ch',  'Ш' => 'Sh',  'Щ' => 'Sch',
            'Ь' => '',    'Ы' => 'Y',   'Ъ' => '',
            'Э' => 'E',   'Ю' => 'Yu',  'Я' => 'Ya',
        ];

        // 1. Транслит
        $str = strtr($string, $converter);
        // 2. В нижний регистр
        $str = mb_strtolower($str);
        // 3. Заменяем пробелы на подчеркивания
        $str = str_replace(' ', '_', $str);
        // 4. Удаляем всё, кроме букв, цифр, точек, тире и нижних подчеркиваний
        $str = preg_replace('/[^a-z0-9\._\-]/', '', $str);
        // 5. Заменяем множественные подчеркивания на одно
        $str = preg_replace('/_+/', '_', $str);

        return trim($str, '_');
    }
}
