<?php

declare(strict_types=1);

ini_set('memory_limit', '512M');

$bannerDirectory = dirname(__DIR__).'/public/img/banner';
$sourceFiles = glob($bannerDirectory.'/*.webp') ?: [];

function writeProgressiveJpeg($source, string $target, int $targetWidth, int $quality): void
{
    $sourceWidth = imagesx($source);
    $sourceHeight = imagesy($source);
    $width = min($targetWidth, $sourceWidth);
    $height = (int) round($sourceHeight * ($width / $sourceWidth));
    $destination = imagecreatetruecolor($width, $height);

    imagecopyresampled(
        $destination,
        $source,
        0,
        0,
        0,
        0,
        $width,
        $height,
        $sourceWidth,
        $sourceHeight
    );
    imageinterlace($destination, true);

    if (!imagejpeg($destination, $target, $quality)) {
        imagedestroy($destination);
        throw new RuntimeException("Could not write {$target}");
    }

    imagedestroy($destination);
}

foreach ($sourceFiles as $sourceFile) {
    $image = imagecreatefromwebp($sourceFile);

    if ($image === false) {
        throw new RuntimeException("Could not decode {$sourceFile}");
    }

    $basePath = $bannerDirectory.'/'.pathinfo($sourceFile, PATHINFO_FILENAME);
    writeProgressiveJpeg($image, $basePath.'-1280.jpg', 1280, 80);
    writeProgressiveJpeg($image, $basePath.'-1920.jpg', 1920, 81);
    writeProgressiveJpeg($image, $basePath.'-2560.jpg', 2560, 82);
    writeProgressiveJpeg($image, $basePath.'-placeholder.jpg', 48, 45);
    imagedestroy($image);

    echo basename($sourceFile).PHP_EOL;
}
