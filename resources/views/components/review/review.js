import {initReviewSlider} from "../swiper/swiper";

const classPrefix = 'review'
const dataPrefix = 'data-review'

const $container = document.querySelector(`[${dataPrefix}]`)

if ($container) {
    review();
}

export function review() {
    // Находим обёртку слайдера
    const $sliderWrapper = $container.querySelector(`[${dataPrefix}-slider-wrapper]`);
    const $cardTemplate = document.querySelector(`[${dataPrefix}-card-template]`);

    // Тестовые данные для сертификатов
    const testreview = [
        {
            name: "Надя Дорофеева",
            desc: "группа «Время и Стекло»",
            title: "Мне безумно понравился интерьер салона – очень стильно! А еще я впервые узнала, что означает «The Fame»! Мастера – настоящие профессионалы, мне качественно и быстро сделали маникюр. Хороший персонал, милые и приятные люди, и очень харизматичный владелец салона!",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/xauthor1.jpg.webp.pagespeed.ic.STc3d-eSCF.webp",
        },
        {
            name: "Надя Дорофеева",
            desc: "группа «Время и Стекло»",
            title: "Мне безумно понравился интерьер салона – очень стильно! А еще я впервые узнала, что означает «The Fame»! Мастера – настоящие профессионалы, мне качественно и быстро сделали маникюр. Хороший персонал, милые и приятные люди, и очень харизматичный владелец салона!",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/xauthor1.jpg.webp.pagespeed.ic.STc3d-eSCF.webp",
        },
        {
            name: "Надя Дорофеева",
            desc: "группа «Время и Стекло»",
            title: "Мне безумно понравился интерьер салона – очень стильно! А еще я впервые узнала, что означает «The Fame»! Мастера – настоящие профессионалы, мне качественно и быстро сделали маникюр. Хороший персонал, милые и приятные люди, и очень харизматичный владелец салона!",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/xauthor1.jpg.webp.pagespeed.ic.STc3d-eSCF.webp",
        },
        {
            name: "Надя Дорофеева",
            desc: "группа «Время и Стекло»",
            title: "Мне безумно понравился интерьер салона – очень стильно! А еще я впервые узнала, что означает «The Fame»! Мастера – настоящие профессионалы, мне качественно и быстро сделали маникюр. Хороший персонал, милые и приятные люди, и очень харизматичный владелец салона!",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/xauthor1.jpg.webp.pagespeed.ic.STc3d-eSCF.webp",
        },
        {
            name: "Надя Дорофеева",
            desc: "группа «Время и Стекло»",
            title: "Мне безумно понравился интерьер салона – очень стильно! А еще я впервые узнала, что означает «The Fame»! Мастера – настоящие профессионалы, мне качественно и быстро сделали маникюр. Хороший персонал, милые и приятные люди, и очень харизматичный владелец салона!",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/xauthor1.jpg.webp.pagespeed.ic.STc3d-eSCF.webp",
        },
        {
            name: "Надя Дорофеева",
            desc: "группа «Время и Стекло»",
            title: "Мне безумно понравился интерьер салона – очень стильно! А еще я впервые узнала, что означает «The Fame»! Мастера – настоящие профессионалы, мне качественно и быстро сделали маникюр. Хороший персонал, милые и приятные люди, и очень харизматичный владелец салона!",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/xauthor1.jpg.webp.pagespeed.ic.STc3d-eSCF.webp",
        },
    ];

    init();

    function init(){
        testreview.forEach(offer => {
            initReviewCard($sliderWrapper, offer);
        });

        initReviewSlider(`${classPrefix}__swiper`);
    }

    // Компонент для создания и заполнения карточки сертификата
    function initReviewCard($container, offer) {
        if (!$cardTemplate) return;

        const clone = $cardTemplate.content.cloneNode(true);

        // Обновляем текст отзыва
        const text = clone.querySelector(`.${classPrefix}__card-text`);
        if (text) {
            text.textContent = offer.title;
        }

        // Обновляем изображение автора
        const img = clone.querySelector('img');
        if (img) {
            img.src = offer.image;
            img.alt = offer.name;
        }

        // Обновляем имя автора
        const name = clone.querySelector(`.${classPrefix}__card-name`);
        if (name) {
            name.textContent = offer.name;
        }

        // Обновляем описание автора
        const footnote = clone.querySelector(`.${classPrefix}__card-footnote`);
        if (footnote) {
            footnote.textContent = offer.desc;
        }

        $container.appendChild(clone);
    }
}
