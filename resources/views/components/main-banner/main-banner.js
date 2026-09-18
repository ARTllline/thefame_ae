const classPrefixBanner = 'main-banner';
const dataPrefixBanner = 'data-main-banner';
const $bannerContainer = document.querySelector(`[${dataPrefixBanner}]`);

if ($bannerContainer) {
    mainBanner();
}

export function mainBanner() {
    const $backgroundSlides = Array.from(
        $bannerContainer.querySelectorAll(`.${classPrefixBanner}__background-slider-item`)
    );

    initBackgroundSlider();

    function initBackgroundSlider() {
        if (!$backgroundSlides.length) {
            return;
        }

        const activeClass = `${classPrefixBanner}__background-slider-item--active`;
        const leavingClass = `${classPrefixBanner}__background-slider-item--leaving`;
        const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
        const rotationDelay = 7000;
        const transitionCleanupDelay = 1600;
        let activeIndex = Math.max(
            0,
            $backgroundSlides.findIndex(slide => slide.classList.contains(activeClass))
        );
        let rotationTimer = null;
        let transitionCleanupTimer = null;
        let nextPreloadScheduled = false;
        const preloadedImages = [];

        const firstImage = $backgroundSlides[activeIndex]
            .querySelector(`[${dataPrefixBanner}-background-image]`);

        if (firstImage && !firstImage.complete) {
            firstImage.addEventListener('load', handleFirstImageSettled, {once: true});
            firstImage.addEventListener('error', handleFirstImageSettled, {once: true});
        } else if (firstImage && firstImage.naturalWidth) {
            handleFirstImageSettled();
        } else {
            handleFirstImageSettled();
        }

        function handleFirstImageSettled() {
            scheduleNextImagePreload();
            scheduleRotation();
        }

        function scheduleNextImagePreload() {
            if (nextPreloadScheduled || $backgroundSlides.length < 2) return;
            nextPreloadScheduled = true;

            const runPreload = () => {
                nextPreloadScheduled = false;
                preloadNextImage();
            };

            if ('requestIdleCallback' in window) {
                window.requestIdleCallback(runPreload, {timeout: 2500});
            } else {
                window.setTimeout(runPreload, 800);
            }
        }

        function preloadNextImage() {
            if ($backgroundSlides.length < 2) return;

            const nextIndex = (activeIndex + 1) % $backgroundSlides.length;
            const nextImage = $backgroundSlides[nextIndex]
                .querySelector(`[${dataPrefixBanner}-background-image]`);

            if (nextImage && !nextImage.complete) {
                const preloadImage = new Image();
                preloadImage.fetchPriority = 'low';
                preloadImage.srcset = nextImage.srcset;
                preloadImage.sizes = nextImage.sizes;
                preloadImage.src = nextImage.currentSrc || nextImage.src;
                preloadedImages.push(preloadImage);
            }
        }

        function showNextSlide() {
            const previousSlide = $backgroundSlides[activeIndex];
            previousSlide.classList.add(leavingClass);
            previousSlide.classList.remove(activeClass);

            activeIndex = (activeIndex + 1) % $backgroundSlides.length;
            $backgroundSlides[activeIndex].classList.add(activeClass);

            window.clearTimeout(transitionCleanupTimer);
            transitionCleanupTimer = window.setTimeout(() => {
                previousSlide.classList.remove(leavingClass);
            }, transitionCleanupDelay);

            scheduleNextImagePreload();
            scheduleRotation();
        }

        function scheduleRotation() {
            window.clearTimeout(rotationTimer);

            if ($backgroundSlides.length > 1 && !document.hidden && !reducedMotion.matches) {
                rotationTimer = window.setTimeout(showNextSlide, rotationDelay);
            }
        }

        document.addEventListener('visibilitychange', scheduleRotation);
        reducedMotion.addEventListener('change', scheduleRotation);
    }

}
