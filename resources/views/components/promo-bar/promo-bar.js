const dataPrefix = 'data-promo-bar';
const classPrefix = 'promo-bar';
const $container = document.querySelector(`[${dataPrefix}]`);

export function promoBar() {
    if (!$container) return;

    const $closeBtn = $container.querySelector('[data-promo-close]');

    // Даем хедеру встать на 0, затем плавно показываем плашку
    setTimeout(() => {
        $container.style.display = 'block';

        // Заставляем браузер перерисовать DOM перед добавлением класса анимации
        void $container.offsetWidth;
        $container.classList.add(`${classPrefix}--visible`);

        // Синхронизируем положение хедера в процессе выезжания плашки (400мс - время CSS анимации)
        let frames = 0;
        const syncHeader = setInterval(() => {
            window.dispatchEvent(new Event('scroll'));
            frames++;
            if (frames > 25) clearInterval(syncHeader);
        }, 16);

    }, 500);


    $closeBtn.addEventListener('click', () => {
        $container.classList.remove(`${classPrefix}--visible`);

        let frames = 0;
        const syncHeader = setInterval(() => {
            window.dispatchEvent(new Event('scroll'));
            frames++;
            if (frames > 25) {
                clearInterval(syncHeader);
                $container.style.display = 'none';
            }
        }, 16);
    });
}

if ($container) {
    promoBar();
}
