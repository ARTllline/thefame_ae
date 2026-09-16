import Swiper from 'swiper/bundle';

export function initOfferSlider(swiperClass) {
    console.log('initOfferSlider swiperINIT');
    const container = document.querySelector("." + swiperClass);
    if (!container) return;

    const swiper = new Swiper(container, {
        slidesPerView: 1,
        spaceBetween: 15,
        watchSlidesProgress: true,
        freeMode: true,
        pagination: {
            el: container.querySelector(".swiper-pagination"),
            clickable: true,
        },
        navigation: {
            nextEl: container.querySelector(".swiper-button-next"),
            prevEl: container.querySelector(".swiper-button-prev"),
        },
        on: {
            progress: function () {
                this.slides.forEach(slide => {
                    if (slide.classList.contains('swiper-slide-visible')) {
                        slide.style.opacity = '1';
                    } else {
                        slide.style.opacity = '0.5';
                    }
                });
            },
            setTransition: function (duration) {
                this.slides.forEach(slide => {
                    slide.style.transitionDuration = duration + 'ms';
                });
            }
        },
        breakpoints: {
            768: {
                spaceBetween: 60,
                slidesPerView: 3,
            }
        }
    });
}

export function initReviewSlider(swiperClass) {
    console.log('initReviewSlider swiperINIT');
    const container = document.querySelector("." + swiperClass);
    if (!container) return;

    const swiper = new Swiper(container, {
        spaceBetween: 20,
        slidesPerView: 1.05,
        watchSlidesProgress: true,
        freeMode: true,
        pagination: {
            el: container.querySelector(".swiper-pagination"),
            clickable: true,
        },
        breakpoints: {
            768: {
                spaceBetween: 60,
                slidesPerView: 1,
            }
        },
        on: {
            progress: function () {
                this.slides.forEach(slide => {
                    if (slide.classList.contains('swiper-slide-visible')) {
                        slide.style.opacity = '1';
                    } else {
                        slide.style.opacity = '0.5';
                    }
                });
            },
            setTransition: function (duration) {
                this.slides.forEach(slide => {
                    slide.style.transitionDuration = duration + 'ms';
                });
            }
        }
    });
}

export function initCertSlider(swiperClass) {
    console.log('initCertSlider swiperINIT');
    const container = document.querySelector("." + swiperClass);
    if (!container) return;

    const swiper = new Swiper(container, {
        spaceBetween: 15,
        slidesPerView: 1.05,
        watchSlidesProgress: true,
        freeMode: true,
        pagination: {
            el: container.querySelector(".swiper-pagination"),
            clickable: true,
        },
        breakpoints: {
            768: {
                spaceBetween: 60,
                slidesPerView: 3,
            }
        },
        navigation: {
            nextEl: container.querySelector(".swiper-button-next"),
            prevEl: container.querySelector(".swiper-button-prev"),
        },
        on: {
            progress: function () {
                this.slides.forEach(slide => {
                    if (slide.classList.contains('swiper-slide-visible')) {
                        slide.style.opacity = '1';
                    } else {
                        slide.style.opacity = '0.5';
                    }
                });
            },
            setTransition: function (duration) {
                this.slides.forEach(slide => {
                    slide.style.transitionDuration = duration + 'ms';
                });
            }
        }
    });
}

export function initAboutSlider(swiperContainer) {
    if (!swiperContainer) return;

    const nextBtn = swiperContainer.querySelector('.swiper-button-next');
    const prevBtn = swiperContainer.querySelector('.swiper-button-prev');
    const paginationEl = swiperContainer.querySelector('.swiper-pagination');

    return new Swiper(swiperContainer, {
        slidesPerView: 1,
        spaceBetween: 0,
        loop: true,
        navigation: {
            nextEl: nextBtn,
            prevEl: prevBtn,
        },
        pagination: {
            el: paginationEl,
            clickable: true,
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

export function initGallerySlider(swiperClass) {
    const swiperContainer = document.querySelector("." + swiperClass);
    if (!swiperContainer) return null;

    return new Swiper(swiperContainer, {
        loop: true, // Включаем бесконечную прокрутку
        slidesPerView: 1,
        spaceBetween: 30,
        watchSlidesProgress: true,
        breakpoints: {
            768: {
                spaceBetween: 30,
                slidesPerView: 3,
            }
        },
        pagination: {
            el: swiperContainer.querySelector(".swiper-pagination"),
            clickable: true,
            dynamicBullets: true, // Включает ограничение по количеству видимых точек
            dynamicMainBullets: 3 // Максимальное количество больших точек (опционально)
        },
        navigation: {
            nextEl: swiperContainer.querySelector(".swiper-button-next"),
            prevEl: swiperContainer.querySelector(".swiper-button-prev"),
        },
    });
}

export function initDeviceSlider(swiperClass, swiperPrevClass) {
    console.log('initDeviceSlider swiperINIT');

    const containerMain = document.querySelector("." + swiperClass);
    const containerPrev = document.querySelector("." + swiperPrevClass);

    if (!containerMain || !containerPrev) return;

    const swiperPrev = new Swiper(containerPrev, {
        spaceBetween: 10,
        slidesPerView: 4,
        freeMode: true,
        watchSlidesProgress: true,
    });

    const swiper = new Swiper(containerMain, {
        slidesPerView: 1,
        spaceBetween: 15,
        watchSlidesProgress: true,
        effect: "fade",
        pagination: {
            el: containerMain.querySelector(".swiper-pagination"),
            clickable: true,
        },
        navigation: {
            nextEl: containerMain.querySelector(".swiper-button-next"),
            prevEl: containerMain.querySelector(".swiper-button-prev"),
        },
        thumbs: {
            swiper: swiperPrev,
        },
    });
}

export function initBannerSlider(swiperClass) {
    console.log('initBannerSliderINIT');
    const container = document.querySelector("." + swiperClass);
    if (!container) return;

    let swiperBanner = new Swiper(container, {
        effect: "creative",
        direction: "vertical",
        slidesPerView: 1,
        centeredSlides: true,
        autoplay: {
            delay: 2500,
            disableOnInteraction: true,
        },
        loop: true,
        creativeEffect: {
            prev: {
                shadow: true,
                translate: [0, -400, 0],
            },
            next: {
                translate: [0, "100%", 0],
            },
        },
    });
}

export function initProductSwiper(swiperClass, swiperPrevClass) {
    console.log('initProductSwiper swiperINIT');

    const containerMain = document.querySelector("." + swiperClass);
    const containerPrev = document.querySelector("." + swiperPrevClass);

    if (!containerMain || !containerPrev) return;

    const swiperPrev = new Swiper(containerPrev, {
        spaceBetween: 10,
        slidesPerView: 3,
        freeMode: true,
        watchSlidesProgress: true,
        breakpoints: {
            768: {
                slidesPerView: 4,
            },
        },
    });

    const swiper = new Swiper(containerMain, {
        slidesPerView: 1,
        spaceBetween: 15,
        watchSlidesProgress: true,
        effect: "fade",
        autoHeight: true,
        pagination: {
            el: containerMain.querySelector(".swiper-pagination"),
            clickable: true,
        },
        navigation: {
            nextEl: containerMain.querySelector(".swiper-button-next"),
            prevEl: containerMain.querySelector(".swiper-button-prev"),
        },
        thumbs: {
            swiper: swiperPrev,
        },
    });
}

export function initGoogleReviewSlider(swiperClass) {
    console.log('initgoogleSlider swiperINIT');
    const container = document.querySelector("." + swiperClass);
    if (!container) return;

    const swiper = new Swiper(container, {
        spaceBetween: 20,
        slidesPerView: 1.2,
        watchSlidesProgress: true,
        freeMode: true,
        pagination: {
            el: container.querySelector(".swiper-pagination"),
            clickable: true,
        },
        breakpoints: {
            768: {
                spaceBetween: 20,
                slidesPerView: 3,
            },
            1280: {
                spaceBetween: 20,
                slidesPerView: 4,
            },
            1420: {
                spaceBetween: 20,
                slidesPerView: 5,
            }
        },
    });
}
