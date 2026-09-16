import { initGallerySlider } from "../swiper/swiper";
import GLightbox from "glightbox";

const classPrefix = 'gallery';
const dataPrefix = 'data-gallery';
const $container = document.querySelector(`[${dataPrefix}]`);

if ($container) {
    gallery();
}

export function gallery() {
    let lightbox = null;
    const swiperClass = `${classPrefix}__swiper`;
    const swiperInstance = initGallerySlider(swiperClass);

    if (!swiperInstance) return;

    function setupLightbox() {
        if (lightbox) return;

        lightbox = GLightbox({
            selector: `.${classPrefix} .swiper-slide:not(.swiper-slide-duplicate) .glightbox`,
            openEffect: 'fade',
            closeEffect: 'fade'
        });
    }

    if (swiperInstance.initialized) {
        setupLightbox();
    } else {
        swiperInstance.on('init', setupLightbox);
    }

    swiperInstance.on('click', (swiper, event) => {
        const e = event || window.event;
        if (!e) return;

        const clickedEl = e.target.closest('.glightbox');
        if (!clickedEl || !lightbox) return;

        if (!clickedEl.closest('.swiper-slide-duplicate')) {
            return;
        }

        e.preventDefault();
        const index = parseInt(clickedEl.getAttribute('data-g-index'), 10);

        if (!isNaN(index)) {
            lightbox.openAt(index);
        }
    });
}

