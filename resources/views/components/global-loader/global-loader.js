const classPrefix = 'global-loader';
const dataPrefix = 'data-global-loader';

// Если элемент в DOM не найден — создаём запасной (так можно вызывать из любого места)
function createMarkup() {
    const wrap = document.createElement('div');
    wrap.setAttribute(dataPrefix, '');
    wrap.className = classPrefix;
    wrap.innerHTML = `
    <div class="${classPrefix}__loader">
      <div class="lds-ripple"><div></div><div></div></div>
    </div>
  `;
    document.body.appendChild(wrap);
    return wrap;
}

const $container = document.querySelector(`[${dataPrefix}]`) || createMarkup();

let counter = 0; // счётчик вызовов show()

function applyShow() {
    $container.classList.add(`active`);
    // блокируем прокрутку страницы (опционально)
    document.documentElement.style.overflow = 'hidden';
}

function applyHide() {
    $container.classList.remove(`active`);
    document.documentElement.style.overflow = '';
}

export const globalLoader = {
    show() {
        // если ещё не было активных запросов — показываем
        if (counter === 0) applyShow();
        counter += 1;
    },

    hide(force = false) {
        if (force) {
            counter = 0;
            applyHide();
            return;
        }
        counter = Math.max(0, counter - 1);
        if (counter === 0) applyHide();
    },

    toggle() {
        if (counter === 0) this.show();
        else this.hide();
    },

    isActive() {
        return counter > 0 || $container.classList.contains(`active`);
    },

    // Для отладки / сброса
    reset() {
        counter = 0;
        applyHide();
    }
};

// Удобство: экспорт по умолчанию и как глобальная переменная (если нужно вызвать без импорта)
export default globalLoader;
window.globalLoader = globalLoader;
