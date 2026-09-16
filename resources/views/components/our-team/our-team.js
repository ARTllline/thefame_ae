// Убедитесь, что класс Swiper импортирован корректно для вашей сборки
// import Swiper from 'swiper';

import Swiper from "swiper";

const classPrefix = 'our-team';
const dataPrefix = 'data-our-team';
const $container = document.querySelector(`[${dataPrefix}]`);

if ($container) {
    ourTeam($container);
}

export function ourTeam(container) {
    const sliderContainer = container.querySelector(`[${dataPrefix}-slider]`);
    if (!sliderContainer) return;

    const nextBtn = sliderContainer.querySelector('.swiper-button-next');
    const prevBtn = sliderContainer.querySelector('.swiper-button-prev');
    const paginationEl = sliderContainer.querySelector('.swiper-pagination');

    return new Swiper(sliderContainer, {
        slidesPerView: 1, // На мобильных
        spaceBetween: 20,
        loop: true,
        navigation: {
            nextEl: nextBtn,
            prevEl: prevBtn,
        },
        breakpoints: {
            // Планшеты
            768: {
                slidesPerView: 2,
                spaceBetween: 40,
            },
            // Десктопы (3 человека на экран)
            1024: {
                slidesPerView: 3,
                spaceBetween: 80, // Расстояние из вашего старого grid-gap
            }
        },
        preventClicks: true,
        preventClicksPropagation: true,
        watchOverflow: true,
        on: {
            imagesReady(swiper) {
                swiper.update();
            }
        }
    });
}
