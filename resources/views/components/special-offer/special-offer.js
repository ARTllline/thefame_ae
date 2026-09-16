import {initOfferSlider} from "../swiper/swiper";
import {specialOfferCard} from "../special-offer-card/special-offer-card";

const classPrefix = 'special-offer'
const dataPrefix = 'data-special-offer'

const $container = document.querySelector(`[${dataPrefix}]`)
console.log('IS OFFER')
console.log($container)

if ($container) {
    specialOffer()
}
export function specialOffer() {
    // Находим обёртку слайдера
    const $sliderWrapper = $container.querySelector(`[${dataPrefix}-slider-wrapper]`);

    const testOffers = [
        {
            title: "Hollywood Skin",
            text: "Отримуй в подарунок 3 регенеруючі процедури HEALITE LUTRONIC",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/ximg_9387-768x1024.jpeg.webp.pagespeed.ic.uGNemeesO_.webp",
            href: "#"
        },
        {
            title: "Another Offer",
            text: "На все процедуры по уходу за лицом действует скидка 70% до 30.07.2021",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/54d84a947d093w719.jpg.webp",
            href: "#"
        },
        {
            title: "Another Offer",
            text: "На все процедуры по уходу за лицом действует скидка 70% до 30.07.2021",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/54d84a947d093w719.jpg.webp",
            href: "#"
        },
        {
            title: "Another Offer",
            text: "На все процедуры по уходу за лицом действует скидка 70% до 30.07.2021",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/54d84a947d093w719.jpg.webp",
            href: "#"
        },
        {
            title: "Another Offer",
            text: "На все процедуры по уходу за лицом действует скидка 70% до 30.07.2021",
            image: "https://thefame.ua/wp-content/webp-express/webp-images/uploads/2020/09/54d84a947d093w719.jpg.webp",
            href: "#"
        },
    ];

    init();

    function init(){
        // testOffers.forEach(offer => {
        //     specialOfferCard({ $container: $sliderWrapper, offer });
        // });

        initOfferSlider(`${classPrefix}__swiper`);
    }

}
