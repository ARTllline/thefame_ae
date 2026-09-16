export const mobileBreakpoint = 1280
export const axios = require('axios');

axios.defaults.headers.common['Content-Type'] = 'application/json';
axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';
axios.defaults.withCredentials = true;

const links = Array.from(document.querySelectorAll('a'))

links.forEach((link) => {
    link.addEventListener('click', (event) => {
        if (link.href.indexOf(window.location.hostname) === -1 && link.href.indexOf('http') !== -1) {
            event.preventDefault()

            window.open(link.href, '_blank');
        }
    })
})
