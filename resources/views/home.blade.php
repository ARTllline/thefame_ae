@extends('templates.main')

@section('meta_title')
    The Fame — modern aesthetic clinic
@endsection

@section('meta_description')
    The Fame — modern aesthetic clinic. We combine a medical approach with care for comfort and aesthetics.
@endsection

@section('preload')
    @php
        $bannerSources = glob(public_path('img/banner/*.webp')) ?: [];
        usort($bannerSources, static function (string $left, string $right): int {
            $preferredImage = 'IMG_1704_4';
            $leftPreferred = str_starts_with(pathinfo($left, PATHINFO_FILENAME), $preferredImage);
            $rightPreferred = str_starts_with(pathinfo($right, PATHINFO_FILENAME), $preferredImage);

            return $leftPreferred === $rightPreferred
                ? strnatcasecmp(basename($left), basename($right))
                : ($leftPreferred ? -1 : 1);
        });
        $firstBannerSource = $bannerSources ? reset($bannerSources) : null;
        $firstBannerName = $firstBannerSource ? pathinfo($firstBannerSource, PATHINFO_FILENAME) : null;
        $bannerAsset = static function (string $suffix) use ($firstBannerName): string {
            $relativePath = 'img/banner/'.$firstBannerName.$suffix;
            $absolutePath = public_path($relativePath);
            $version = is_file($absolutePath) ? filemtime($absolutePath) : null;

            return asset($relativePath).($version ? '?v='.$version : '');
        };
    @endphp
    @if($firstBannerName)
        <link
            rel="preload"
            as="image"
            href="{{ $bannerAsset('-1280.jpg') }}"
            imagesrcset="{{ $bannerAsset('-1280.jpg') }} 1280w, {{ $bannerAsset('-1920.jpg') }} 1920w, {{ $bannerAsset('-2560.jpg') }} 2560w"
            imagesizes="100vw"
            fetchpriority="high"
        >
    @endif
@endsection

@section('content')
    <section id="hero">
        @include('components.main-banner.main-banner')
    </section>

    <!-- Добавили класс reveal-section к блокам ниже -->
    <section id="About_The_Fame" >
        @include('components.main-about.main-about', ['about' => $aboutMain])
    </section>


    <section id="Services_&_Price" >
        @include('components.services.services', ['categories' => $categories])
    </section>

    <section id="Our_Devices" >
        @include('components.devices.devices', ['devices' => $devices])
    </section>

    <section id="Before_After" >
        @include('components.gallery.gallery', ['gallery' => $gallery])
    </section>

    <section id="Our_Team" >
        @include('components.our-team.our-team', ['team' => $team])
    </section>
{{--    class="reveal-section"--}}

    <section id="Contacts" >

        @include('components.call-us.call-us', ['modifier' => 'footer'])

        <div class="footer-section">
            @include('components.locations.locations')
            @include('components.contact.contact')
            @include('components.footer.footer')
        </div>
    </section>

    @include('components.social.social')

@endsection
