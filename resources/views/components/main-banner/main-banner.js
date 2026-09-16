import { initBannerSlider } from "../swiper/swiper";
import { persistUtmFromUrl, readUtmCookies } from "../utils/utm";

const classPrefixBanner = 'main-banner';
const dataPrefixBanner = 'data-main-banner';
const $bannerContainer = document.querySelector(`[${dataPrefixBanner}]`);

// Сохраняем UTM-метки
persistUtmFromUrl();

if ($bannerContainer) {
    mainBanner();
}

export function mainBanner() {
    const $backgroundVideo = $bannerContainer.querySelector(`[${dataPrefixBanner}-background-video]`);
    const $backgroundLoader = $bannerContainer.querySelector(`[${dataPrefixBanner}-background-loader]`);
    const $beautyProButton = $bannerContainer.querySelector(`[${dataPrefixBanner}-beautypro]`);

    const mediaQuery = window.matchMedia('(max-width: 767px)');
    let currentMode = mediaQuery.matches ? 'mobile' : 'desktop';
    let beautyProLink = 'https://beautyprosoftware.com/b/997907';

    // 1. Логика кнопки BeautyPro
    if ($beautyProButton) {
        let isClicking = false;
        $beautyProButton.addEventListener('click', async (e) => {
            e.preventDefault();
            if (isClicking) return;
            isClicking = true;
            $beautyProButton.setAttribute('aria-disabled', 'true');

            const urlParams = new URLSearchParams(window.location.search);
            const cookieUtm = readUtmCookies();

            const utm_source = urlParams.get('utm_source') || cookieUtm.utm_source || '';
            const utm_medium = urlParams.get('utm_medium') || cookieUtm.utm_medium || '';
            const utm_campaign = urlParams.get('utm_campaign') || cookieUtm.utm_campaign || '';
            const utm_term = urlParams.get('utm_term') || cookieUtm.utm_term || '';
            const utm_content = urlParams.get('utm_content') || cookieUtm.utm_content || '';
            const referrer = document.referrer || cookieUtm.referrer || '';
            const landing_page = window.location.href || cookieUtm.landing_page || '';

            const payload = {
                target: beautyProLink,
                utm_source, utm_medium, utm_campaign, utm_term, utm_content,
                referrer, landing_page
            };

            const tokenMeta = document.querySelector('meta[name="csrf-token"]');
            const csrf = tokenMeta ? tokenMeta.getAttribute('content') : '';

            try {
                const controller = new AbortController();
                const signal = controller.signal;
                const fetchPromise = fetch('/track-beautypro-click', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': csrf,
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify(payload),
                    signal
                }).then(r => r.ok ? r.json().catch(()=>null) : null);

                const timeoutMs = 1200;
                const timeoutPromise = new Promise(resolve => setTimeout(() => resolve(null), timeoutMs));
                const result = await Promise.race([fetchPromise, timeoutPromise]);

                let destination = beautyProLink;
                if (result && result.success && result.uuid) {
                    const sep = destination.includes('?') ? '&' : '?';
                    destination = `${destination}${sep}ref_uuid=${encodeURIComponent(result.uuid)}`;
                }

                window.location.href = destination;

            } catch (err) {
                window.location.href = beautyProLink;
            } finally {
                isClicking = false;
                $beautyProButton.removeAttribute('aria-disabled');
            }
        });
    }

    // 2. Логика фонового видео
    if ($backgroundVideo) {
        initVideo();
    }

    function initVideo() {
        setVideoSource(currentMode);
        $backgroundVideo.addEventListener('loadeddata', hideLoader);

        mediaQuery.addEventListener('change', (e) => {
            const newMode = e.matches ? 'mobile' : 'desktop';
            if (newMode !== currentMode) {
                currentMode = newMode;
                setVideoSource(currentMode);
            }
        });
    }

    function getVideoUrl(mode) {
        return mode === 'mobile'
            ? $bannerContainer.getAttribute('data-dubai-mobile')
            : $bannerContainer.getAttribute('data-dubai-desktop');
    }

    function setVideoSource(mode) {
        const videoUrl = getVideoUrl(mode);

        if ($backgroundVideo.getAttribute('src') !== videoUrl) {
            $backgroundVideo.src = videoUrl;
            $backgroundVideo.load();
        }
    }

    function hideLoader() {
        if ($backgroundLoader) {
            $backgroundLoader.style.display = 'none';
        }
    }
}
