import GLightbox from "glightbox";
import { initAboutSlider } from "../swiper/swiper";

const classPrefix = 'about';
const dataPrefix = 'data-about';
const $container = document.querySelector(`[${dataPrefix}]`);
if ($container) about();

export function about() {
    init();

    // 1. Инициализируем lightbox ТОЛЬКО для элементов внутри .about
    const lightbox = GLightbox({
        selector: `.${classPrefix} .glightbox`,
        openEffect: 'fade',
        closeEffect: 'fade'
    });

    document.addEventListener('click', (e) => {
        // 2. Перехватываем клик ТОЛЬКО если он был внутри секции about
        const a = e.target.closest(`.${classPrefix} .glightbox`);
        if (!a) return;

        if (e.ctrlKey || e.metaKey || e.button === 1) return;

        e.preventDefault();
        e.stopImmediatePropagation();

        const gallery = a.getAttribute('data-gallery') || '';
        const selector = gallery
            ? `.${classPrefix} .glightbox[data-gallery="${gallery}"]`
            : `.${classPrefix} .glightbox`;

        const group = Array.from(document.querySelectorAll(selector));
        const index = group.indexOf(a);

        if (typeof lightbox.openAt === 'function') {
            lightbox.openAt(index >= 0 ? index : 0);
        } else if (typeof lightbox.open === 'function') {
            lightbox.open();
        }
    }, true);

    function init(){
        const sliderImageClass = `${classPrefix}__swiper-image`;
        initAboutSlider(sliderImageClass);
    }
}
