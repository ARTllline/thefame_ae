const classPrefixSocial = 'social';
const dataPrefixSocial = 'data-social';
const $socialContainer = document.querySelector(`[${dataPrefixSocial}]`);

if ($socialContainer) {
    social();
}

export function social() {

    window.addEventListener('scroll', handleScroll);
    handleScroll();


    function handleScroll() {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        //console.log(scrollTop)

        if (scrollTop > 180) {
            $socialContainer.classList.add(`${classPrefixSocial}--dark`);
        } else {
            $socialContainer.classList.remove(`${classPrefixSocial}--dark`);
        }
    }
}
