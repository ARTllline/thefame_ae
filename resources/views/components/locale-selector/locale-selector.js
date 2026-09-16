const dataPrefix = 'data-locale-selector';
const classPrefix = 'locale-selector';
const $container = document.querySelector(`[${dataPrefix}]`);

if ($container) {
    localeSelector();
}

export function localeSelector() {
    const $locales = $container.querySelectorAll(`[${dataPrefix}-locale]`);
    const $form = $container.querySelector(`[${dataPrefix}-form]`);
    const $localeInput = $container.querySelector(`[${dataPrefix}-input]`);

    $locales.forEach(locale => {
        locale.addEventListener('click', function() {
            const selectedLocale = locale.getAttribute('data-locale');
            $localeInput.value = selectedLocale;
            $form.submit();
        });
    });

    const $openButtons = document.querySelectorAll('[data-locale-open]');
    $openButtons.forEach((button) => {
        button.addEventListener('click', (e) => {
            e.preventDefault();
            openModal();
        });
    });


    function openModal() {
        $container.classList.add(`${classPrefix}--active`);
    }

    function closeModal() {
        $container.classList.remove(`${classPrefix}--active`);
    }
}
