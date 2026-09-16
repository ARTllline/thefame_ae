import { initDeviceSlider } from "../swiper/swiper";
import GLightbox from 'glightbox';

const classPrefix = 'devices';
const dataPrefix  = 'data-devices';

const $container = document.querySelector(`[${dataPrefix}]`);
if ($container) {
    devices();
}

export function devices() {

    GLightbox({
        selector: `.${classPrefix} .glightbox`,
        openEffect: 'fade',
        closeEffect: 'fade'
    });

    const $cards = $container.querySelectorAll(`[${dataPrefix}-card]`);
    $cards.forEach(initCard);

    function initCard($card) {
        const index     = $card.dataset.devicesCardIndex;
        const imgClass  = `${classPrefix}__swiper-image-${index}`;
        const prevClass = `${classPrefix}__swiper-${index}`;
        initDeviceSlider(imgClass, prevClass);

        const $text    = $card.querySelector(`.${classPrefix}__card-content-text`);
        const $btnMore = $card.querySelector(`[${dataPrefix}-read-more]`);
        const $btnLess = $card.querySelector(`[${dataPrefix}-read-less]`);
        if (!$text || !$btnMore || !$btnLess) return;

        const initialMax = parseFloat(getComputedStyle($text).maxHeight);

        if ($text.scrollHeight <= initialMax) {
            $btnMore.style.display = 'none';
            return;
        }
        $btnLess.style.display = 'none';

        $text.style.transition = 'max-height 0.4s ease';

        $btnMore.addEventListener('click', () => {
            $text.style.maxHeight = $text.scrollHeight + 'px';
            $btnMore.style.display = 'none';
            $btnLess.style.display = 'flex';
        });

        $btnLess.addEventListener('click', () => {
            $text.style.maxHeight = initialMax + 'px';
            $btnMore.style.display = 'flex';
            $btnLess.style.display = 'none';
        });
    }
}
