document.addEventListener('DOMContentLoaded', () => {
    initScrollReveal();
    initFrontendLimits();
});

/**
 * 1. Красивое появление блоков при скролле (Intersection Observer)
 */
function initScrollReveal() {
    const sections = document.querySelectorAll('.reveal-section');

    if (sections.length === 0) return;

    const observerOptions = {
        root: null, // отслеживаем относительно вьюпорта
        rootMargin: '0px',
        threshold: 0.15 // блок начнет проявляться, когда 15% его высоты вошли в экран
    };

    const sectionObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('reveal-section--visible');
                // Отписываемся от слежки за этим блоком, чтобы анимация не проигрывалась повторно
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    sections.forEach(section => {
        sectionObserver.observe(section);
    });
}

/**
 * 2. Фронтенд скрытие и раскрытие элементов (Услуги, Девайсы, Команда)
 */
function initFrontendLimits() {
    // Конфигурация: селектор кнопки => { селектор карточек, базовый лимит, сколько добавлять за раз }
    const limitsConfig = {
        'services': { cardSelector: '.services__card', initialCount: 9, step: 9 },
        'devices':  { cardSelector: '.devices__card', initialCount: 4, step: 4 },
        'team':     { cardSelector: '.our-team__card', initialCount: 9, step: 9 }
    };

    Object.keys(limitsConfig).forEach(key => {
        const btn = document.querySelector(`[data-load-more="${key}"]`);
        if (!btn) return;

        const config = limitsConfig[key];
        // Находим все карточки строго внутри родительской секции этой кнопки
        const sectionContainer = btn.closest('section');
        const cards = Array.from(sectionContainer.querySelectorAll(config.cardSelector));

        let currentVisibleCount = config.initialCount;

        // Функция обновления видимости карточек
        const updateCardsVisibility = (isInitial = false) => {
            cards.forEach((card, index) => {
                if (index < currentVisibleCount) {
                    // Если это раскрытие по клику — добавляем легкий эффект появления для новых карт
                    if (!isInitial && card.classList.contains('card-hidden-load')) {
                        card.style.opacity = '0';
                        card.style.transform = 'translateY(15px)';
                        card.style.transition = 'opacity 0.4s ease, transform 0.4s ease';

                        card.classList.remove('card-hidden-load');

                        // Форсируем перерисовку для срабатывания анимации
                        void card.offsetHeight;
                        card.style.opacity = '1';
                        card.style.transform = 'translateY(0)';
                    } else {
                        card.classList.remove('card-hidden-load');
                    }
                } else {
                    card.classList.add('card-hidden-load');
                }
            });

            // Если показали всё — скрываем саму кнопку "Показать еще"
            if (currentVisibleCount >= cards.length) {
                const wrapper = btn.closest('.show-more-wrapper');
                if (wrapper) wrapper.style.display = 'none';
                btn.style.display = 'none';
            }
        };

        // Инициализируем первоначальное скрытие
        updateCardsVisibility(true);

        // Вешаем обработчик на клик кнопки
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            currentVisibleCount += config.step;
            updateCardsVisibility(false);

            // После раскрытия обновляем инстансы Swiper/GLightbox, если они привязаны к картам
            window.dispatchEvent(new Event('resize'));
        });
    });
}
