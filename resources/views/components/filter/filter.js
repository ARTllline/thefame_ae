const classPrefix = 'filter'
const dataPrefix = 'data-filter'

const $containerFilters = document.querySelectorAll(`[${dataPrefix}]`)

if ($containerFilters.length > 0) {
    $containerFilters.forEach($container => {
        filter($container)
    })
}

export function filter($container) {

    init()
    function init() {
        console.log($container)
        const header = $container.querySelector(`.${classPrefix}__header`)
        const body = $container.querySelector(`.${classPrefix}__body`)
        const items = Array.from($container.querySelectorAll(`.${classPrefix}__list-item`))
        const filterFor = $container.getAttribute('data-filter-for') ?? null

        const selected = getSelected($container)
        // $container.dispatchEvent(new CustomEvent('catalogueFilters.change', {
        //     detail: {filterFor, selected},
        //     bubbles: true
        // }))

        // Ensure body has initial styles for animation
        body.style.overflow = 'hidden'
        body.style.height = '' // let CSS decide initial if any
        body.style.transition = 'height 260ms cubic-bezier(.4,0,.2,1)'

        // Accessibility attributes
        header.setAttribute('role', 'button')
        header.setAttribute('tabindex', '0')

        // Determine initial open state (default: open)
        const isInitiallyOpen = !$container.classList.contains(`${classPrefix}__-closed`)
        header.setAttribute('aria-expanded', isInitiallyOpen ? 'true' : 'false')

        // Prepare items
        items.forEach(item => {
            item.setAttribute('role', 'checkbox')
            item.setAttribute('tabindex', '0')
            item.setAttribute('aria-checked', 'false')
            item.dataset.checked = 'false'
        })

        // Helper to animate open/close
        function animateOpenClose(open) {
            // Respect reduced motion preference
            const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches
            const startHeight = body.getBoundingClientRect().height
            // Temporarily set height to current computed to start transition reliably
            body.style.height = `${startHeight}px`

            // Force reflow so the starting height is applied
            // eslint-disable-next-line no-unused-expressions
            body.offsetHeight

            if (open) {
                // make body visible (if display none used elsewhere)
                body.style.display = '' // allow css to manage display
                const targetHeight = body.scrollHeight
                if (prefersReduced) {
                    // jump to final state without animation
                    body.style.height = ''
                    $container.classList.remove(`${classPrefix}--closed`)
                    header.setAttribute('aria-expanded', 'true')
                    return
                }
                // animate to scrollHeight
                body.style.height = `${targetHeight}px`
                $container.classList.remove(`${classPrefix}--closed`)
                header.setAttribute('aria-expanded', 'true')

                const onEnd = (e) => {
                    if (e.target !== body || e.propertyName !== 'height') return
                    // remove inline height so content can grow/shrink naturally
                    body.style.height = ''
                    body.removeEventListener('transitionend', onEnd)
                }
                body.addEventListener('transitionend', onEnd)
            } else {
                // closing: animate from current height -> 0
                if (prefersReduced) {
                    $container.classList.add(`${classPrefix}--closed`)
                    header.setAttribute('aria-expanded', 'false')
                    body.style.height = '0px'
                    return
                }
                // ensure we have the exact start height, then transition to 0
                // give a frame to allow the start height to take effect
                requestAnimationFrame(() => {
                    body.style.height = '0px'
                    const onEnd = (e) => {
                        if (e.target !== body || e.propertyName !== 'height') return
                        // keep closed class for styling
                        $container.classList.add(`${classPrefix}--closed`)
                        // hide content from assistive tech if desired (optional)
                        // body.style.display = 'none'
                        body.removeEventListener('transitionend', onEnd)
                    }
                    body.addEventListener('transitionend', onEnd)
                })
                header.setAttribute('aria-expanded', 'false')
            }
        }

        // Simple wrapper: setOpen(true/false) — uses animateOpenClose
        function setOpen(open) {
            animateOpenClose(!!open)
        }

        function toggleOpen() {
            const isOpen = !$container.classList.contains(`${classPrefix}--closed`)
            setOpen(!isOpen)
        }

        header.addEventListener('click', toggleOpen)
        header.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault()
                toggleOpen()
            }
        })

        // Item toggle (same as before)
        function setItemChecked(item, checked) {
            item.classList.toggle('is-checked', checked)
            item.dataset.checked = checked ? 'true' : 'false'
            item.setAttribute('aria-checked', checked ? 'true' : 'false')
        }

        function itemClickHandler(e, item) {
            const currently = item.dataset.checked === 'true'
            setItemChecked(item, !currently)
            const selected = getSelected($container)
            $container.dispatchEvent(new CustomEvent('catalogueFilters.change', {
                detail: {filterFor, selected},
                bubbles: true
            }))
        }

        items.forEach(item => {
            item.addEventListener('click', (e) => itemClickHandler(e, item))
            item.addEventListener('keydown', (e) => {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault()
                    itemClickHandler(e, item)
                }
            })
        })

        // If initial state is closed, ensure styles reflect that
        if (!isInitiallyOpen) {
            // set height to 0 so it starts closed
            $container.classList.add(`${classPrefix}--closed`)
            body.style.height = '0px'
            header.setAttribute('aria-expanded', 'false')
        } else {
            // leave open; clear inline height to allow natural height
            body.style.height = ''
            header.setAttribute('aria-expanded', 'true')
        }
    }


    // getSelected helper (same as before)
    function getSelected(filterOrFilterFor) {
        let filterEl = null
        if (typeof filterOrFilterFor === 'string' || typeof filterOrFilterFor === 'number') {
            filterEl = $container.querySelector(`[${dataPrefix}][data-filter-for="${filterOrFilterFor}"]`)
        } else if (filterOrFilterFor instanceof Element) {
            filterEl = filterOrFilterFor
        } else {
            // вернуть все фильтры в виде { key: [values] }
            const all = {}
            const allFilters = Array.from($container.querySelectorAll(`[${dataPrefix}]`))
            allFilters.forEach(f => {
                const key = f.getAttribute('data-filter-for') ?? null
                all[key] = Array.from(f.querySelectorAll(`.${classPrefix}__list-item.is-checked`))
                    .map(i => (i.dataset.filterValue ?? i.getAttribute('data-filter-value') ?? i.getAttribute('data-filter-value') ?? i.textContent).trim())
            })
            return all
        }

        if (!filterEl) return []
        return Array.from(filterEl.querySelectorAll(`.${classPrefix}__list-item.is-checked`))
            .map(i => {
                // отдать data-filter-value если он есть, иначе текст
                const dv = i.getAttribute('data-filter-value') ?? i.dataset.filterValue
                return (typeof dv !== 'undefined' && dv !== null) ? dv.toString().trim() : i.textContent.trim()
            })
    }

    $container.catalogueFilters = {
        getSelected
    }

    return {
        getSelected
    }
}

