import { initBannerSlider } from "../swiper/swiper";

const classPrefix = 'header';
const dataPrefix = 'data-header';
const $container = document.querySelector(`[${dataPrefix}]`);

if ($container) {
    header();
}

export function header() {
    const $mobileMenuToggle = $container.querySelector(`[${dataPrefix}-menu-open]`);
    const menuList = $container.querySelector(`.${classPrefix}__menu-list`);
    const menuItems = Array.from($container.querySelectorAll(`.${classPrefix}__menu-list-item`));
    const closeBtns = Array.from($container.querySelectorAll(`[${dataPrefix}-body-menu-close]`));
    const anchorLinks = $container.querySelectorAll(`a[href^="#"]`);

    const $promoBar = document.querySelector('[data-promo-bar]');

    const threshold = $container.offsetHeight;
    let lastScrollTop = window.pageYOffset || document.documentElement.scrollTop;
    let isScrollingFromClick = false;

    init();

    function init() {
        window.addEventListener('scroll', handleHeader);

        // ВЫЗЫВАЕМ СРАЗУ, ЧТОБЫ ЗАДАТЬ ВЕРНЫЙ ОТСТУП ПРИ ЗАГРУЗКЕ
        handleHeader();

        if ($mobileMenuToggle) {
            $mobileMenuToggle.addEventListener('click', toggleMobileMenu);
        }

        // ... (остальной код событий из вашего файла остается без изменений)
        anchorLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                const targetId = link.getAttribute('href');
                if (targetId !== '#' && targetId.length > 1) {
                    isScrollingFromClick = true;
                    closeMobileMenu();

                    setTimeout(() => {
                        isScrollingFromClick = false;
                    }, 800);
                }
            });
        });
    }

    function toggleMobileMenu() {
        if ($container.classList.contains(`${classPrefix}--open`)) {
            closeMobileMenu();
        } else {
            openMobileMenu();
        }
    }

    function openMobileMenu() {
        $container.classList.add(`${classPrefix}--open`);
        document.documentElement.classList.add('no-scroll');
    }

    function closeMobileMenu() {
        $container.classList.remove(`${classPrefix}--open`);
        document.documentElement.classList.remove('no-scroll');
        closeAllSubmenus();
    }

    function closeAllSubmenus() {
        menuItems.forEach(item => {
            item.querySelector(`.${classPrefix}__menu-list-item-body--active`)?.classList.remove(`${classPrefix}__menu-list-item-body--active`);
            item.querySelector(`.${classPrefix}__menu-list-item-title--active`)?.classList.remove(`${classPrefix}__menu-list-item-title--active`);
        });
    }

    menuItems.forEach(item => {
        const title = item.querySelector(`.${classPrefix}__menu-list-item-title`);
        const submenu = item.querySelector(`.${classPrefix}__menu-list-item-body`);
        if (!title || !submenu) return;

        title.addEventListener('click', e => {
            e.stopPropagation();
            const isActive = submenu.classList.contains(`${classPrefix}__menu-list-item-body--active`);
            closeAllSubmenus();

            if (!isActive) {
                title.classList.add(`${classPrefix}__menu-list-item-title--active`);
                submenu.classList.add(`${classPrefix}__menu-list-item-body--active`);
            }
        });
    });

    closeBtns.forEach(btn => {
        btn.addEventListener('click', e => {
            e.stopPropagation();
            closeAllSubmenus();
        });
    });

    document.addEventListener('click', e => {
        if (!$container.contains(e.target)) {
            closeAllSubmenus();
        }
    });

    window.addEventListener('resize', () => {
        if (window.innerWidth > 767 && $container.classList.contains(`${classPrefix}--open`)) {
            closeMobileMenu();
        }
    });

    function handleHeader() {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

        let promoHeight = 0;
        if ($promoBar) {
            promoHeight = $promoBar.getBoundingClientRect().height;
        }
        const offset = Math.max(0, promoHeight - scrollTop);
        $container.style.top = `${offset}px`;
        $container.style.setProperty('--promo-offset', `${offset}px`);

        if (!isScrollingFromClick) {
            if (scrollTop > threshold && scrollTop > lastScrollTop) {
                $container.classList.add(`${classPrefix}--hidden`);
            } else if (scrollTop < lastScrollTop) {
                $container.classList.remove(`${classPrefix}--hidden`);
            }
        }

        if (scrollTop > 0) {
            $container.classList.add(`${classPrefix}--scrolled`);
        } else {
            $container.classList.remove(`${classPrefix}--scrolled`);
        }

        lastScrollTop = scrollTop <= 0 ? 0 : scrollTop;
    }
}
