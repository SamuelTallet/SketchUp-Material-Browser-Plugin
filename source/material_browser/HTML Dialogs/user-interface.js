/**
 * Material Browser (MBR) UI.
 *
 * @package MBR extension for SketchUp
 *
 * @copyright © 2025 Samuel Tallet
 *
 * @licence GNU General Public License 3.0
 */

/**
 * Material Browser plugin namespace.
 */
MaterialBrowser = {}

/**
 * Help/FAQ URL.
 */
MaterialBrowser.HELP_URL = 'https://github.com/SamuelTallet/SketchUp-Material-Browser-Plugin?#helpfaq'

/**
 * Donation URL.
 */
MaterialBrowser.DONATE_URL = 'https://raw.githubusercontent.com/SamuelTallet/SketchUp-Material-Browser-Plugin/main/config/donate.url'

/**
 * Donation URL fallback.
 */
MaterialBrowser.DONATE_URL_FALLBACK = 'https://www.paypal.me/SamuelTallet'

/**
 * Loading screen animation timer ID.
 * @type {?number}
 */
MaterialBrowser.loadAnimationTimer = null

/**
 * Settings overlay.
 * @type {?HTMLElement}
 */
MaterialBrowser.settingsOverlay = null

/**
 * Settings commit button.
 * @type {?HTMLElement}
 */
MaterialBrowser.settingsCommit = null

/**
 * Display name checkbox.
 * @type {?HTMLInputElement}
 */
MaterialBrowser.displayName = null

/**
 * Display custom SKM checkbox.
 * @type {?HTMLInputElement}
 */
MaterialBrowser.displayCustomSKM = null

/**
 * Display profile SKM checkbox.
 * @type {?HTMLInputElement}
 */
MaterialBrowser.displayProfileSKM = null

/**
 * Display built-in SKM checkbox.
 * @type {?HTMLInputElement}
 */
MaterialBrowser.displayBuiltinSKM = null

/**
 * Display Poly Haven checkbox.
 * @type {?HTMLInputElement}
 */
MaterialBrowser.displayPolyHaven = null

/**
 * Loading screen.
 * @type {?HTMLElement}
 */
MaterialBrowser.loadingScreen = null

/**
 * Loading screen cards.
 * @type {?NodeListOf<SVGGElement>}
 */
MaterialBrowser.loadingCards = null

/**
 * Loading screen text.
 * @type {?HTMLElement}
 */
MaterialBrowser.loadingText = null

/**
 * Zoom slider.
 * @type {?HTMLInputElement}
 */
MaterialBrowser.zoomSlider = null

/**
 * Zoom in icon.
 * @type {?HTMLElement}
 */
MaterialBrowser.zoomInIcon = null

/**
 * Zoom out icon.
 * @type {?HTMLElement}
 */
MaterialBrowser.zoomOutIcon = null

/**
 * Eye icon.
 * @type {?HTMLElement}
 */
MaterialBrowser.eyeIcon = null

/**
 * SKM folder icon.
 * @type {?HTMLElement}
 */
MaterialBrowser.skmFolderIcon = null

/**
 * Help icon.
 * @type {?HTMLElement}
 */
MaterialBrowser.helpIcon = null

/**
 * Heart icon.
 * @type {?HTMLElement}
 */
MaterialBrowser.heartIcon = null

/**
 * Filter by type dropdown.
 * @type {?HTMLSelectElement}
 */
MaterialBrowser.filterByType = null

/**
 * Materials zone.
 * Not to be confused with `materialsList`.
 * @type {?HTMLElement}
 */
MaterialBrowser.materialsZone = null

/**
 * Materials list.
 * @type {?HTMLElement}
 */
MaterialBrowser.materialsList = null

/**
 * Status bar.
 * @type {?HTMLElement}
 */
MaterialBrowser.statusBar = null

/**
 * Selects static DOM elements to avoid repeated queries.
 */
MaterialBrowser.selectElements = () => {
    MaterialBrowser.settingsOverlay = document.querySelector('#settings')
    MaterialBrowser.settingsCommit = document.querySelector('#settings .commit')
    MaterialBrowser.displayName = document.querySelector('[data-setting="display_name"]')
    MaterialBrowser.displayCustomSKM = document.querySelector('[data-setting="display_custom_skm"]')
    MaterialBrowser.displayProfileSKM = document.querySelector('[data-setting="display_profile_skm"]')
    MaterialBrowser.displayBuiltinSKM = document.querySelector('[data-setting="display_builtin_skm"]')
    MaterialBrowser.displayPolyHaven = document.querySelector('[data-setting="display_poly_haven"]')

    MaterialBrowser.loadingScreen = document.querySelector('#loading')
    MaterialBrowser.loadingCards = document.querySelectorAll('#loading .card')
    MaterialBrowser.loadingText = document.querySelector('#loading .text')

    MaterialBrowser.zoomSlider = document.querySelector('#toolbar .zoom .slider')
    MaterialBrowser.zoomInIcon = document.querySelector('#toolbar .zoom .in.icon')
    MaterialBrowser.zoomOutIcon = document.querySelector('#toolbar .zoom .out.icon')
    MaterialBrowser.eyeIcon = document.querySelector('#toolbar .eye.icon')
    MaterialBrowser.skmFolderIcon = document.querySelector('#toolbar .skm-folder.icon')
    MaterialBrowser.helpIcon = document.querySelector('#toolbar .help.icon')
    MaterialBrowser.heartIcon = document.querySelector('#toolbar .heart.icon')
    MaterialBrowser.filterByType = document.querySelector('#toolbar .filter-by-type')

    MaterialBrowser.materialsZone = document.querySelector('#materials')
    MaterialBrowser.materialsList = document.querySelector('#materials .list')

    MaterialBrowser.statusBar = document.querySelector('#status-bar')
}

/**
 * Shows status bar.
 *
 * @param {string} text Text to display in status bar.
 */
MaterialBrowser.showStatusBar = (text) => {
    MaterialBrowser.statusBar.textContent = text
    MaterialBrowser.statusBar.classList.add('displayed')
}

/**
 * Hides status bar.
 */
MaterialBrowser.hideStatusBar = () => {
    MaterialBrowser.statusBar.classList.remove('displayed')
    MaterialBrowser.statusBar.textContent = ''
}

/**
 * Starts loading screen' animation.
 */
MaterialBrowser.startLoadingAnimation = () => {
    MaterialBrowser.loadAnimationTimer = setInterval(() => {
        MaterialBrowser.loadingCards.forEach((card, index) => {
            card.style.opacity = 0
            setTimeout(() => {
                card.style.opacity = 1
            }, (index + 1) * 150) // Cards anims are staggered.
        })
    }, 3000) // Whole anim repeats every 3s until stopped.
}

/**
 * Stops loading screen' animation.
 */
MaterialBrowser.stopLoadingAnimation = () => {
    if (MaterialBrowser.loadAnimationTimer === null) return

    clearInterval(MaterialBrowser.loadAnimationTimer)
}

/**
 * Shows loading screen.
 *
 * @param {string} text Text to display in loading screen.
 */
MaterialBrowser.showLoadingScreen = (text) => {
    MaterialBrowser.materialsZone.classList.add('hidden')
    MaterialBrowser.loadingText.textContent = text
    MaterialBrowser.loadingScreen.classList.add('displayed')
    MaterialBrowser.startLoadingAnimation()
}

/**
 * Hides loading screen.
 */
MaterialBrowser.hideLoadingScreen = () => {
    MaterialBrowser.stopLoadingAnimation()
    MaterialBrowser.loadingScreen.classList.remove('displayed')
    MaterialBrowser.loadingText.textContent = ''
    MaterialBrowser.materialsZone.classList.remove('hidden')
}

/**
 * Shows display settings overlay.
 */
MaterialBrowser.showDisplaySettings = () => {
    MaterialBrowser.materialsZone.classList.add('hidden')
    MaterialBrowser.settingsOverlay.classList.add('displayed')
}

/**
 * Hides display settings overlay.
 */
MaterialBrowser.hideDisplaySettings = () => {
    MaterialBrowser.settingsOverlay.classList.remove('displayed')
    MaterialBrowser.materialsZone.classList.remove('hidden')
}

/**
 * Applies "zoom value" setting.
 */
MaterialBrowser.applyZoomValue = () => {
    const zoomValue = parseInt(MaterialBrowser.zoomSlider.value)

    document.documentElement.style.setProperty('--thumbnail-size', zoomValue + 'px')
    // Names and sources logos are scaled accordingly to thumbnail size, in CSS.

    sketchup.setZoomValue(zoomValue)
}

/**
 * Adds zoom slider change event listener.
 */
MaterialBrowser.listenZoomChange = () => {
    MaterialBrowser.zoomSlider.addEventListener('change', _event => {
        MaterialBrowser.applyZoomValue()
    })
}

/**
 * Adds zoom in button click event listener.
 */
MaterialBrowser.listenZoomInClick = () => {
    MaterialBrowser.zoomInIcon.addEventListener('click', _event => {

        let zoomValue = parseInt(MaterialBrowser.zoomSlider.value)

        if (zoomValue === parseInt(MaterialBrowser.zoomSlider.max)) return

        zoomValue += parseInt(MaterialBrowser.zoomSlider.step)
        MaterialBrowser.zoomSlider.value = zoomValue

        MaterialBrowser.applyZoomValue()

    })
}

/**
 * Adds zoom out button click event listener.
 */
MaterialBrowser.listenZoomOutClick = () => {
    MaterialBrowser.zoomOutIcon.addEventListener('click', event => {

        let zoomValue = parseInt(MaterialBrowser.zoomSlider.value)

        if (zoomValue === parseInt(MaterialBrowser.zoomSlider.min)) return

        zoomValue -= parseInt(MaterialBrowser.zoomSlider.step)
        MaterialBrowser.zoomSlider.value = zoomValue

        MaterialBrowser.applyZoomValue()

    })
}

/**
 * Adds display settings open icon click event listener.
 */
MaterialBrowser.listenDisplaySettingsOpen = () => {
    MaterialBrowser.eyeIcon.addEventListener('click', _event => {
        MaterialBrowser.showDisplaySettings()
    })
}

/**
 * Adds display settings commit button click event listener.
 */
MaterialBrowser.listenDisplaySettingsCommit = () => {
    MaterialBrowser.settingsCommit.addEventListener('click', _event => {
        MaterialBrowser.hideDisplaySettings()
        MaterialBrowser.applyDisplaySettings()
    })
}

/**
 * Applies "Display name" setting.
 */
MaterialBrowser.applyDisplayName = () => {
    const displayName = MaterialBrowser.displayName.checked
    document.documentElement.style.setProperty('--name-display', displayName ? 'block' : 'none')

    sketchup.setDisplayName(displayName)
}

/**
 * Applies "Display custom/profile/built-in SKM", and "Display Poly Haven" settings.
 */
MaterialBrowser.applyDisplaySources = () => {
    const dcs = MaterialBrowser.displayCustomSKM.checked
    const dps = MaterialBrowser.displayProfileSKM.checked
    const dbs = MaterialBrowser.displayBuiltinSKM.checked
    const dph = MaterialBrowser.displayPolyHaven.checked

    sketchup.setDisplaySources(dcs, dps, dbs, dph)
}

/**
 * Applies display settings.
 */
MaterialBrowser.applyDisplaySettings = () => {
    MaterialBrowser.applyDisplayName()
    MaterialBrowser.applyDisplaySources()
}

/**
 * Adds SKM folder icon click event listener.
 */
MaterialBrowser.listenSKMFolderClick = () => {
    MaterialBrowser.skmFolderIcon.addEventListener('click', _event => {
        sketchup.setCustomSKMPath()
    })
}

/**
 * Adds help icon click event listener.
 */
MaterialBrowser.listenHelpClick = () => {
    MaterialBrowser.helpIcon.addEventListener('click', _event => {
        sketchup.openURL(MaterialBrowser.HELP_URL)
    })
}

/**
 * Adds heart icon click event listener.
 */
MaterialBrowser.listenHeartClick = () => {
    MaterialBrowser.heartIcon.addEventListener('click', _event => {
        fetch(MaterialBrowser.DONATE_URL)
            .then(response => response.text())
            .then(url => {
                sketchup.openURL(url)
            })
            .catch(error => {
                console.error("Can't fetch URL to donate:", error)
                sketchup.openURL(MaterialBrowser.DONATE_URL_FALLBACK)
            })
    })
}

/**
 * Applies "Type filter value" setting.
 */
MaterialBrowser.applyTypeFilterValue = () => {
    const typeFilterValue = MaterialBrowser.filterByType.value

    if (typeFilterValue === 'all') {
        const materials = document.querySelectorAll('.material')

        materials.forEach(material => {
            material.classList.remove('hidden')
        })
    } else {
        const materialsToDisplay = document.querySelectorAll(
            '.material[data-type="' + typeFilterValue + '"]'
        )
        const materialsToHide = document.querySelectorAll(
            '.material:not([data-type="' + typeFilterValue + '"])'
        )

        materialsToDisplay.forEach(materialToDisplay => {
            materialToDisplay.classList.remove('hidden')
        })

        materialsToHide.forEach(materialToHide => {
            materialToHide.classList.add('hidden')
        })
    }

    sketchup.setTypeFilterValue(typeFilterValue)
}

/**
 * Adds filter by type dropdown change event listener.
 */
MaterialBrowser.listenFilterByTypeChange = () => {
    MaterialBrowser.filterByType.addEventListener('change', _event => {
        MaterialBrowser.applyTypeFilterValue()
    })
}

/**
 * Adds delegated event listener for thumbnail clicks.
 * Event delegation avoids creating a lot of listeners.
 */
MaterialBrowser.listenThumbnailClicks = () => {
    MaterialBrowser.materialsZone.addEventListener('click', event => {
        /** @type {?HTMLElement} */
        const element = event.target

        if (!element.classList.contains('thumbnail')) return

        if (element.classList.contains('model-material')) {
            sketchup.selectModelMaterial(element.dataset.name)
        } else if (element.classList.contains('skm-file')) {
            sketchup.selectSKMFile(element.dataset.path)
        } else if (element.classList.contains('ph-texture')) {
            sketchup.selectPolyHavenTexture(element.dataset.slug)
        }
    })
}

/**
 * Adds loading screen click event listener.
 * In case backend crashes, we provide user a way to hide loading screen.
 */
MaterialBrowser.listenLoadingScreenClick = () => {
    MaterialBrowser.loadingScreen.addEventListener('click', _event => {
        MaterialBrowser.hideLoadingScreen()
    })
}

/**
 * Adds delegated click event listener for source logos with `data-url` attribute.
 */
MaterialBrowser.listenSourceLogoClicks = () => {
    MaterialBrowser.materialsZone.addEventListener('click', event => {
        /** @type {?HTMLElement} */
        const element = event.target

        if (!element.classList.contains('source-logo') || !element.hasAttribute('data-url')) return

        sketchup.openURL(element.dataset.url)
    })
}

/**
 * Adds delegated hover event listeners for elements with `data-status` attribute.
 */
MaterialBrowser.listenElemsWithStatusHovers = () => {
    document.body.addEventListener('mouseover', event => {
        /** @type {?HTMLElement} */
        const element = event.target

        if (!element.hasAttribute('data-status')) return

        MaterialBrowser.showStatusBar(element.dataset.status)
    })

    document.body.addEventListener('mouseout', event => {
        /** @type {?HTMLElement} */
        const element = event.target

        if (!element.hasAttribute('data-status')) return

        MaterialBrowser.hideStatusBar()
    })
}

/**
 * Adds event listeners.
 */
MaterialBrowser.addEventListeners = () => {

    MaterialBrowser.listenZoomChange()
    MaterialBrowser.listenZoomInClick()
    MaterialBrowser.listenZoomOutClick()

    MaterialBrowser.listenDisplaySettingsOpen()
    MaterialBrowser.listenDisplaySettingsCommit()

    MaterialBrowser.listenSKMFolderClick()
    MaterialBrowser.listenHelpClick()
    MaterialBrowser.listenHeartClick()

    MaterialBrowser.listenFilterByTypeChange()

    MaterialBrowser.listenThumbnailClicks()
    MaterialBrowser.listenLoadingScreenClick()
    MaterialBrowser.listenSourceLogoClicks()

    MaterialBrowser.listenElemsWithStatusHovers()

}

// When document is ready:
document.addEventListener('DOMContentLoaded', _event => {

    MaterialBrowser.selectElements()

    // Restore last used material type filter value.
    MaterialBrowser.applyTypeFilterValue()

    // Show materials list now.
    // Not before, to prevent FOUC.
    MaterialBrowser.materialsList.classList.add('displayed')

    // Make material list searchable
    const list = new List('materials', options = {
        valueNames: ['name'] // by name.
    })

    MaterialBrowser.addEventListeners()

    list.on('searchComplete', _event => {
        // Fix "thumbnail size desync" issue when user:
        // searches a material then changes thumbnail size then searches again.
        MaterialBrowser.applyZoomValue()
    })

})
