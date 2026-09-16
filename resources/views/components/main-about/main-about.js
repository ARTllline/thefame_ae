import { initAboutSlider } from "../swiper/swiper";
import GLightbox from "glightbox";

const classPrefix = 'main-about';
const dataPrefix = 'data-main-about';
const $container = document.querySelector(`[${dataPrefix}]`);

if ($container) {
    mainAbout();
}

export function mainAbout() {
    const $imageSelector = $container.querySelector(`[${dataPrefix}-image]`);

    const $textWrapper = $container.querySelector('[data-main-about-text-wrapper]');
    const $textInner = $container.querySelector('[data-main-about-text]');
    const $moreBtn = $container.querySelector('[data-main-about-more]');

    const collapsedHeight = 220;

    if ($textWrapper && $textInner && $moreBtn) {
        if ($textInner.scrollHeight <= collapsedHeight) {
            $moreBtn.classList.add('is-hidden');
            $textWrapper.classList.add('no-fade');
            $textWrapper.style.maxHeight = 'none';
        } else {
            $textWrapper.style.maxHeight = `${collapsedHeight}px`;

            $moreBtn.addEventListener('click', () => {
                const isExpanded = $textWrapper.classList.toggle('is-expanded');
                const textMore = $moreBtn.getAttribute('data-text-more');
                const textLess = $moreBtn.getAttribute('data-text-less');

                if (isExpanded) {
                    $textWrapper.style.maxHeight = `${$textInner.scrollHeight}px`;
                    $moreBtn.innerText = textLess;

                    setTimeout(() => {
                        if ($textWrapper.classList.contains('is-expanded')) {
                            $textWrapper.style.maxHeight = 'none';
                        }
                    }, 400);
                } else {
                    $textWrapper.style.maxHeight = `${$textInner.scrollHeight}px`;

                    requestAnimationFrame(() => {
                        $textWrapper.style.maxHeight = `${collapsedHeight}px`;
                    });
                    $moreBtn.innerText = textMore;
                }
            });
        }
    }

    const lightbox = GLightbox({
        selector: '.glightbox',
        openEffect: 'fade',
        closeEffect: 'fade'
    });

    const $swiperContainer = $container.querySelector(`[${dataPrefix}-image]`);
    const swiper = initAboutSlider($swiperContainer);

    if (swiper && $imageSelector) {
        swiper.on('sliderMove', () => {
            $imageSelector.classList.add('is-dragging');
        });

        swiper.on('touchEnd transitionEnd', () => {
            setTimeout(() => {
                $imageSelector.classList.remove('is-dragging');
            }, 50);
        });
    }
}
