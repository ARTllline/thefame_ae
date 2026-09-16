<?php

namespace App\Services\MediaLibrary;

use Spatie\MediaLibrary\MediaCollections\Models\Media;
use Spatie\MediaLibrary\Support\PathGenerator\DefaultPathGenerator;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;

class CustomPathGeneretor extends DefaultPathGenerator
{
    /*
    * Get a unique base path for the given media.
    */
    protected function getBasePath(Media $media): string
    {
        $prefix = config('media-library.prefix', '');
        if ($prefix !== '') {
            return $prefix . '/' . $media->getKey();
        }

        $prefix = '';
        if ($media->disk != 'public') {
            $prefix = $media->disk . '/';
        }
        return $prefix . $media->id;


//        $prefix = config('media-library.prefix', '');
//        // https://stackoverflow.com/questions/2211197/how-should-i-format-user-uploaded-pictures-filenames
//
//        $datePath = Str::of($media->created_at->format('Y-m-d'))->replace('-', DIRECTORY_SEPARATOR)->value;
//        $key = $media->model_type.DIRECTORY_SEPARATOR.$datePath.DIRECTORY_SEPARATOR.$media->model_id.DIRECTORY_SEPARATOR
//            .$media->uuid; // $media->getKey();
//
//        if ($prefix !== '') {
//            return $prefix.'/'.$key;
//        }
//
//        return $key;
    }
}
