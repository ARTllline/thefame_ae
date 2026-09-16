import axios from "axios";
import Notification from '../notification/notification-es';
import { readUtmCookies } from '../utils/utm';

const classPrefix = 'modal';
const dataPrefix = 'data-modal';
const $container = document.querySelector(`[${dataPrefix}]`);
const popup = Notification({ isHidePrev: true });

if ($container) {
    modal();
}

export function modal() {
    if (!$container) return;

    const $formWrapper = $container.querySelector(`[${dataPrefix}-form]`);
    const $successPage = $container.querySelector(`[${dataPrefix}-success]`);
    const requestErrorMessage = $container.dataset.modalRequestError || 'An error has occurred';

    const $nameContainer = $formWrapper.querySelector(`[${dataPrefix}-name]`);
    const $phoneContainer = $formWrapper.querySelector(`[${dataPrefix}-phone]`);
    const $treatmentContainer = $formWrapper.querySelector(`[${dataPrefix}-treatment]`);

    const $closeButtons = $container.querySelectorAll(`[${dataPrefix}-close], [${dataPrefix}-success-close]`);
    const $submitButton = $formWrapper.querySelector(`[${dataPrefix}-submit]`);

    // Поля ввода
    const $nameInput = $nameContainer.querySelector('input[name="name"]');
    const $phoneInput = $phoneContainer.querySelector('input[name="phone"]');
    const $treatmentInput = $treatmentContainer.querySelector('textarea[name="treatment"]');
    const $regionInput = $container.querySelector(`[${dataPrefix}-region]`);

    // Ошибочные сообщения
    const $nameErr = $nameContainer.querySelector(`.${classPrefix}__container-input-err-message`);
    const $phoneErr = $phoneContainer.querySelector(`.${classPrefix}__container-input-err-message`);
    const defaultNameError = $nameErr.textContent;
    const defaultPhoneError = $phoneErr.textContent;

    const $promoSubtitle = $container.querySelector(`[${dataPrefix}-promo-subtitle]`);
    const $formTypeInput = $container.querySelector(`[${dataPrefix}-form-type]`);
    let resetTimer = null;
    let isSubmitting = false;

    // Сброс модалки в исходное состояние
    const resetModalState = () => {
        $formWrapper.style.display = '';
        $formWrapper.style.opacity = '';
        $formWrapper.style.transform = '';
        $formWrapper.style.transition = '';

        $successPage.style.display = 'none';
        $successPage.classList.remove(`${classPrefix}__success-page--active`);

        $nameErr.textContent = defaultNameError;
        $phoneErr.textContent = defaultPhoneError;
        $nameErr.style.opacity = '0';
        $phoneErr.style.opacity = '0';
        $nameContainer.classList.remove(`${classPrefix}__container-input--error`);
        $phoneContainer.classList.remove(`${classPrefix}__container-input--error`);

        $nameInput.value = '';
        $phoneInput.value = '';
        if ($treatmentInput) $treatmentInput.value = '';

        // Прячем промо-заголовок и возвращаем тип формы по умолчанию
        if ($promoSubtitle) $promoSubtitle.style.display = 'none';
        if ($formTypeInput) $formTypeInput.value = 'standard';

        isSubmitting = false;
        $submitButton.disabled = false;
        $submitButton.removeAttribute('aria-busy');
    };

    const closeModal = () => {
        $container.classList.remove(`${classPrefix}--active`);
        clearTimeout(resetTimer);
        resetTimer = setTimeout(resetModalState, 400);
    };

    const openModal = (isPromo = false) => {
        clearTimeout(resetTimer);
        resetModalState();
        if (isPromo) {
            if ($promoSubtitle) $promoSubtitle.style.display = 'block';
            if ($formTypeInput) $formTypeInput.value = 'promo_appointment';
        }
        $container.classList.add(`${classPrefix}--active`);
    };

    $closeButtons.forEach(btn => btn.addEventListener('click', closeModal));

    $container.addEventListener('click', (e) => {
        if (e.target === $container) {
            closeModal();
        }
    });

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && $container.classList.contains(`${classPrefix}--active`)) {
            closeModal();
        }
    });

    const openButtons = document.querySelectorAll('[data-modal-open]');
    openButtons.forEach((button) => {
        button.addEventListener('click', (e) => {
            e.preventDefault();
            // Проверяем, нажата ли именно плашка
            const isPromo = button.getAttribute('data-modal-open') === 'promo';
            openModal(isPromo);
        });
    });

    if (!$submitButton || $formWrapper.dataset.listenerAdded === 'true') return;
    $formWrapper.dataset.listenerAdded = 'true';

    $formWrapper.addEventListener('submit', async (e) => {
        e.preventDefault();
        await send();
    });

    async function send() {
        if (isSubmitting) return;

        $nameErr.style.opacity = '0';
        $phoneErr.style.opacity = '0';
        $nameContainer.classList.remove(`${classPrefix}__container-input--error`);
        $phoneContainer.classList.remove(`${classPrefix}__container-input--error`);

        const name = $nameInput.value.trim();
        const phone = $phoneInput.value.trim();
        const treatment = $treatmentInput ? $treatmentInput.value.trim() : '';
        const region = $regionInput ? $regionInput.value.trim() : '';

        let hasError = false;

        if (!name) {
            $nameErr.style.opacity = '1';
            $nameContainer.classList.add(`${classPrefix}__container-input--error`);
            hasError = true;
        }

        const phoneDigits = phone.replace(/\D/g, '');
        if (phoneDigits.length < 10 || phoneDigits.length > 15) {
            $phoneErr.style.opacity = '1';
            $phoneContainer.classList.add(`${classPrefix}__container-input--error`);
            hasError = true;
        }

        if (hasError) return;

        const utm = readUtmCookies();

        isSubmitting = true;
        $submitButton.disabled = true;
        $submitButton.setAttribute('aria-busy', 'true');

        const formType = $formTypeInput ? $formTypeInput.value : 'standard';
        const landingPage = utm.landing_page || window.location.href;
        const fromPage = formType === 'promo_appointment'
            ? `promo_appointment: ${landingPage}`.slice(0, 255)
            : landingPage.slice(0, 255);

        try {
            const payload = {
                name,
                phone,
                treatment,
                region,
                from_page: fromPage,
                utm_source: utm.utm_source || null,
                utm_medium: utm.utm_medium || null,
                utm_campaign: utm.utm_campaign || null,
                utm_term: utm.utm_term || null,
                utm_content: utm.utm_content || null,
                referrer: utm.referrer || null,
            };

            const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
            const response = await axios.post('/appointment', payload, {
                headers: {
                    Accept: 'application/json',
                    ...(csrfToken ? { 'X-CSRF-TOKEN': csrfToken } : {}),
                },
            });

            if (response.data?.success) {
                $nameInput.value = '';
                $phoneInput.value = '';
                if ($treatmentInput) $treatmentInput.value = '';

                $formWrapper.style.opacity = '0';
                $formWrapper.style.display = 'none';
                $successPage.style.display = 'block';
                void $successPage.offsetWidth;
                $successPage.classList.add(`${classPrefix}__success-page--active`);

                window.dataLayer = window.dataLayer || [];
            } else {
                popup.error({ message: response.data?.message || requestErrorMessage });
            }
        } catch (error) {
            if (error.response?.status === 422) {
                const errors = error.response.data.errors || {};
                if (errors.name) {
                    $nameErr.textContent = errors.name[0];
                    $nameErr.style.opacity = '1';
                    $nameContainer.classList.add(`${classPrefix}__container-input--error`);
                }
                if (errors.phone) {
                    $phoneErr.textContent = errors.phone[0];
                    $phoneErr.style.opacity = '1';
                    $phoneContainer.classList.add(`${classPrefix}__container-input--error`);
                }

                const unhandledError = Object.entries(errors)
                    .find(([field]) => !['name', 'phone'].includes(field));

                if (unhandledError) {
                    popup.error({ message: unhandledError[1][0] || requestErrorMessage });
                } else if (!errors.name && !errors.phone) {
                    popup.error({ message: requestErrorMessage });
                }
            } else {
                popup.error({ message: error.response?.data?.message || requestErrorMessage });
            }
        } finally {
            isSubmitting = false;
            $submitButton.disabled = false;
            $submitButton.removeAttribute('aria-busy');
        }
    }
}
