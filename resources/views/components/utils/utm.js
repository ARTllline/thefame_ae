
function getQueryParam(name) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(name) || '';
}

function setCookie(name, value, days = 30) {
    const expires = new Date(Date.now() + days * 864e5).toUTCString();
    document.cookie = `${encodeURIComponent(name)}=${encodeURIComponent(value)}; path=/; expires=${expires}`;
}

function getCookie(name) {
    const match = document.cookie.match(new RegExp('(?:^|; )' + encodeURIComponent(name) + '=([^;]*)'));
    return match ? decodeURIComponent(match[1]) : '';
}

export function persistUtmFromUrl() {
    // якщо вже в cookie — не перезаписуємо (щоб зберегти перший контакт)
    const keys = ['utm_source','utm_medium','utm_campaign','utm_term','utm_content','referrer','landing_page'];
    let hasNew = false;

    // Якщо на сторінці є utm - зберігаємо їх, або зберігаємо реферер/landing
    const utm = {
        utm_source: getQueryParam('utm_source'),
        utm_medium: getQueryParam('utm_medium'),
        utm_campaign: getQueryParam('utm_campaign'),
        utm_term: getQueryParam('utm_term'),
        utm_content: getQueryParam('utm_content'),
    };

    // landing page — перший URL сторінки (без параметрів)
    const landing = window.location.origin + window.location.pathname;

    // referrer
    const ref = document.referrer || '';

    // Записуємо тільки якщо cookie порожні або якщо в URL є utm
    keys.forEach((k) => {
        const cur = getCookie(k);
        if (!cur) {
            if (k.startsWith('utm_')) {
                const val = utm[k] || '';
                if (val) {
                    setCookie(k, val, 30);
                    hasNew = true;
                }
            } else if (k === 'referrer') {
                if (ref) {
                    setCookie('referrer', ref, 30);
                    hasNew = true;
                }
            } else if (k === 'landing_page') {
                setCookie('landing_page', landing, 30);
                hasNew = true;
            }
        } else {
            // cookie вже є — нічого не робимо (фіксуємо перший контакт)
        }
    });

    // Повертаємо об'єкт (беремо з cookie щоб бути впевненими)
    const result = {};
    keys.forEach(k => result[k] = getCookie(k) || '');
    return result;
}

export function readUtmCookies() {
    const keys = ['utm_source','utm_medium','utm_campaign','utm_term','utm_content','referrer','landing_page'];
    const result = {};
    keys.forEach(k => result[k] = getCookie(k) || '');
    return result;
}
