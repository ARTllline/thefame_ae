<!doctype html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, maximum-scale=5.0, minimum-scale=1.0">

    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <link rel="apple-touch-icon" href="/images/favicon.ico">
    <link rel="icon" type="image/x-icon" href="/images/favicon.ico">
    <link rel="shortcut icon" type="image/x-icon" href="/images/favicon.ico">

    <title>@yield('meta_title')</title>
    <meta name="description" content="@yield('meta_description')">

    @yield('meta')

    @php
        $latestAsset = static function (string $pattern): ?string {
            $files = glob(public_path($pattern)) ?: [];
            usort($files, static function (string $left, string $right): int {
                return (filemtime($left) <=> filemtime($right)) ?: strcmp($left, $right);
            });

            return $files ? end($files) : null;
        };

        $criticalJs = $latestAsset('dist/critical-*.js');
        $mainJs = $latestAsset('dist/main-*.js');
        $mainCss = $latestAsset('dist/main-*.css');
    @endphp

    @if($criticalJs)
        <script defer fetchpriority="high" src="{{ asset('dist/'.basename($criticalJs)) }}"></script>
    @endif
    @if($mainJs)
        <script defer src="{{ asset('dist/'.basename($mainJs)) }}"></script>
    @endif

    @yield('preload')

    <!-- Google Tag Manager -->
    <script>window.dataLayer = window.dataLayer || [];</script>
    <script>(function (w, d, s, l, i) {
            w[l] = w[l] || [];
            w[l].push({
                'gtm.start':
                    new Date().getTime(), event: 'gtm.js'
            });
            var f = d.getElementsByTagName(s)[0],
                j = d.createElement(s), dl = l != 'dataLayer' ? '&l=' + l : '';
            j.async = true;
            j.src =
                'https://www.googletagmanager.com/gtm.js?id=' + i + dl;
            f.parentNode.insertBefore(j, f);
        })(window, document, 'script', 'dataLayer', 'GTM-5KV8H8D4');</script>
    <!-- End Google Tag Manager -->

    @if($mainCss)
        <style>
            {!! file_get_contents($mainCss) !!}
        </style>
    @endif
</head>
<body>
<!-- Google Tag Manager (noscript) -->
<noscript>
    <iframe src="https://www.googletagmanager.com/ns.html?id=GTM-5KV8H8D4"
            height="0" width="0" style="display:none;visibility:hidden"></iframe>
</noscript>
<!-- End Google Tag Manager (noscript) -->


@include('parts.icon-sprite')
@include('components.promo-bar.promo-bar')
@include('components.header.header')
@yield('content')

@include('components.modal.modal')
@include('components.locale-selector.locale-selector')
@include('components.global-loader.global-loader')


<!-- Meta Pixel Code -->
<script>
    !function (f, b, e, v, n, t, s) {
        if (f.fbq) return;
        n = f.fbq = function () {
            n.callMethod ?
                n.callMethod.apply(n, arguments) : n.queue.push(arguments)
        };
        if (!f._fbq) f._fbq = n;
        n.push = n;
        n.loaded = !0;
        n.version = '2.0';
        n.queue = [];
        t = b.createElement(e);
        t.async = !0;
        t.src = v;
        s = b.getElementsByTagName(e)[0];
        s.parentNode.insertBefore(t, s)
    }(window, document, 'script',
        'https://connect.facebook.net/en_US/fbevents.js');
    fbq('init', '2145944932542038');
    fbq('track', 'PageView');
</script>
<noscript><img height="1" width="1" style="display:none"
               src="https://www.facebook.com/tr?id=2145944932542038&ev=PageView&noscript=1"
    /></noscript>
<!-- End Meta Pixel Code -->

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
</body>
</html>
