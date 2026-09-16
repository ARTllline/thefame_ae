import {initCertSlider} from "../swiper/swiper";

const classPrefix = 'certificates'
const dataPrefix = 'data-certificates'

const $container = document.querySelector(`[${dataPrefix}]`)

if ($container) {
    certificates();
}

export function certificates() {
    // Находим обёртку слайдера
    const $sliderWrapper = $container.querySelector(`[${dataPrefix}-slider-wrapper]`);
    const $cardTemplate = document.querySelector(`[${dataPrefix}-card-template]`);

    // Тестовые данные для сертификатов
    const testCertificates = [
        {
            title: "Cтатус специалистов подтвержден академией Sassoon",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/xawwardsslider1.jpg.webp.pagespeed.ic.TGYqa-e1p0.webp",
        },
        {
            title: "Cтатус специалистов подтвержден академией Sassoon",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/xawwardsslider1.jpg.webp.pagespeed.ic.TGYqa-e1p0.webp",
        },
        {
            title: "Cтатус специалистов подтвержден академией Sassoon",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/xawwardsslider1.jpg.webp.pagespeed.ic.TGYqa-e1p0.webp",
        },
        {
            title: "Cтатус специалистов подтвержден академией Sassoon",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/xawwardsslider1.jpg.webp.pagespeed.ic.TGYqa-e1p0.webp",
        },
        {
            title: "Cтатус специалистов подтвержден академией Sassoon",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/xawwardsslider1.jpg.webp.pagespeed.ic.TGYqa-e1p0.webp",
        },
    ];

    init();

    function init(){
        testCertificates.forEach(offer => {
            initCertificateCard($sliderWrapper, offer);
        });

        initCertSlider(`${classPrefix}__swiper`);
    }

    // Компонент для создания и заполнения карточки сертификата
    function initCertificateCard($container, offer) {
        if (!$cardTemplate) return;

        const clone = $cardTemplate.content.cloneNode(true);

        // Обновляем изображение
        const img = clone.querySelector('img');
        if (img) {
            img.src = offer.image;
            img.alt = offer.title;
        }

        const subtitle = clone.querySelector(`.${classPrefix}__card-subtitle`);
        if (subtitle) {
            subtitle.textContent = offer.title;
        }

        $container.appendChild(clone);
    }
}
