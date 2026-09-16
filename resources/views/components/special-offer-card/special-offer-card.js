const classPrefix = 'special-offer-card'
const dataPrefix = 'data-special-offer-card'
//const $container = document.querySelector(`[${dataPrefix}]`)

export function specialOfferCard({$container}) {
   // const template = document.querySelector(`[${dataPrefix}-template]`);

    const $card = document.querySelector(`[${dataPrefix}]`);
    init();

     function init() {

         if (!$card) return;
        // if (!template) return;
        //
        // // Клонируем содержимое шаблона
        // const clone = template.content.cloneNode(true);
        //
        // // Обновляем ссылку карточки
        // const cardLink = clone.querySelector(`[${dataPrefix}]`);
        // if (cardLink) {
        //     cardLink.href = offer.href;
        // }
        //
        // // Обновляем изображение
        // const img = clone.querySelector('img');
        // if (img) {
        //     img.src = offer.image;
        //     img.alt = offer.title;
        // }
        //
        // // Обновляем заголовок карточки
        // const titleElem = clone.querySelector(`.${classPrefix}__title`);
        // if (titleElem) {
        //     titleElem.textContent = offer.title;
        // }
        //
        // // Обновляем текст описания карточки
        // const textElem = clone.querySelector(`.${classPrefix}__text`);
        // if (textElem) {
        //     textElem.textContent = offer.text;
        // }
        //
        // // Добавляем заполненную карточку в переданный контейнер
        $container.appendChild($card);
    }
}
