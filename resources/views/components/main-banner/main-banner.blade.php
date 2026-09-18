@php
    $classPrefix ='main-banner';
    $dataPrefix ='data-main-banner';

    $bannerSources = glob(public_path('img/banner/*.webp')) ?: [];
    usort($bannerSources, static function (string $left, string $right): int {
        $preferredImage = 'IMG_1704_4';
        $leftPreferred = str_starts_with(pathinfo($left, PATHINFO_FILENAME), $preferredImage);
        $rightPreferred = str_starts_with(pathinfo($right, PATHINFO_FILENAME), $preferredImage);

        return $leftPreferred === $rightPreferred
            ? strnatcasecmp(basename($left), basename($right))
            : ($leftPreferred ? -1 : 1);
    });
    $versionedAsset = static function (string $relativePath): string {
        $absolutePath = public_path($relativePath);
        $version = is_file($absolutePath) ? filemtime($absolutePath) : null;

        return asset($relativePath).($version ? '?v='.$version : '');
    };
    $bannerImages = array_map(static function (string $source) use ($versionedAsset): array {
        $name = pathinfo($source, PATHINFO_FILENAME);
        $relativePath = 'img/banner/'.$name;
        $placeholderPath = public_path($relativePath.'-placeholder.jpg');

        return [
            'small' => $versionedAsset($relativePath.'-1280.jpg'),
            'medium' => $versionedAsset($relativePath.'-1920.jpg'),
            'large' => $versionedAsset($relativePath.'-2560.jpg'),
            'placeholder' => is_file($placeholderPath)
                ? 'data:image/jpeg;base64,'.base64_encode(file_get_contents($placeholderPath))
                : null,
        ];
    }, array_values($bannerSources));
@endphp

<div {{$dataPrefix}} class="{{$classPrefix}}">

    <div {{$dataPrefix}}-background class="{{$classPrefix}}__background">
        <div {{$dataPrefix}}-background-slider class="{{$classPrefix}}__background-slider">
            @foreach($bannerImages as $image)
                <div
                    class="{{$classPrefix}}__background-slider-item{{ $loop->first ? ' '.$classPrefix.'__background-slider-item--first '.$classPrefix.'__background-slider-item--active' : '' }}"
                    @if($image['placeholder']) style="background-image: url({{ $image['placeholder'] }})" @endif
                >
                    <img
                        {{$dataPrefix}}-background-image
                        class="{{$classPrefix}}__background-slider-item-img"
                        src="{{ $image['small'] }}"
                        srcset="{{ $image['small'] }} 1280w, {{ $image['medium'] }} 1920w, {{ $image['large'] }} 2560w"
                        sizes="100vw"
                        alt=""
                        aria-hidden="true"
                        @if($loop->first)
                            fetchpriority="high"
                        @else
                            fetchpriority="low"
                            loading="lazy"
                            decoding="async"
                        @endif
                    >
                </div>
            @endforeach
        </div>
    </div>

    <div class="{{$classPrefix}}__content">
        <h1 class="{{$classPrefix}}__title">{{ __('static.banner_title') }}</h1>
        <p class="{{$classPrefix}}__subtitle">{{ __('static.banner_subtitle') }}</p>
    </div>


</div>
