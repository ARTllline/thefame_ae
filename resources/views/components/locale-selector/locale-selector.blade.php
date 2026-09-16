@php
    $classPrefix = 'locale-selector';
    $dataPrefix = 'data-locale-selector';

    if (!function_exists('getLocalizedUrl')) {
        function getLocalizedUrl($newLocale) {
            $segments = request()->segments();
            $urlLocales = ['ru', 'ua', 'en'];

            if (count($segments) > 0 && in_array($segments[0], $urlLocales)) {
                $segments[0] = $newLocale;
            } else {
                array_unshift($segments, $newLocale);
            }

            return url(implode('/', $segments)) . (request()->getQueryString() ? '?' . request()->getQueryString() : '');
        }
    }
@endphp

<div {{$dataPrefix}} class="{{$classPrefix}}">
    <div class="{{$classPrefix}}__content">
        <h2 class="{{$classPrefix}}__title">{{__('static.select_locale')}}</h2>
        <div {{$dataPrefix}}-locales class="{{$classPrefix}}__locales">

            <a href="{{ getLocalizedUrl('en') }}" class="{{$classPrefix}}__locale">
                English
            </a>

            <a href="{{ getLocalizedUrl('ua') }}" class="{{$classPrefix}}__locale">
                Українська
            </a>

                <a href="{{ getLocalizedUrl('ru') }}" class="{{ $classPrefix }}__locale">
                    Русский
                </a>

        </div>
    </div>
</div>
