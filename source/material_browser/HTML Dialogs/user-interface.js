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
 * Donation URL.
 */
MaterialBrowser.DONATE_URL = 'https://raw.githubusercontent.com/SamuelTallet/SketchUp-Material-Browser-Plugin/main/config/donate.url'

/**
 * Donation URL fallback.
 */
MaterialBrowser.DONATE_URL_FALLBACK = 'https://www.paypal.me/SamuelTallet'

/**
 * Loading screen animation timer ID.
 * @type {number|null}
 */
MaterialBrowser.loadAnimationTimer = null

/**
 * Starts loading screen' animation.
 */
MaterialBrowser.startLoadingAnimation = () => {
    /** @type {NodeListOf<SVGGElement>} */
    const cards = document.querySelectorAll('#loading .card')

    MaterialBrowser.loadAnimationTimer = setInterval(() => {
        cards.forEach((card, index) => {
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
    if ( MaterialBrowser.loadAnimationTimer === null ) return

    clearInterval(MaterialBrowser.loadAnimationTimer)
}

/**
 * Shows loading screen.
 */
MaterialBrowser.showLoadingScreen = () => {
    document.querySelector('#materials').classList.add('hidden')
    document.querySelector('#loading').classList.add('displayed')
    MaterialBrowser.startLoadingAnimation()
}

/**
 * Hides loading screen.
 */
MaterialBrowser.hideLoadingScreen = () => {
    MaterialBrowser.stopLoadingAnimation()
    document.querySelector('#loading').classList.remove('displayed')
    document.querySelector('#materials').classList.remove('hidden')
}

/**
 * Shows settings overlay.
 */
MaterialBrowser.showSettingsOverlay = () => {
    document.querySelector('#materials').classList.add('hidden')
    document.querySelector('#settings').classList.add('displayed')
}

/**
 * Hides settings overlay.
 */
MaterialBrowser.hideSettingsOverlay = () => {
    document.querySelector('#settings').classList.remove('displayed')
    document.querySelector('#materials').classList.remove('hidden')
}

/**
 * Adds event listeners.
 */
MaterialBrowser.addEventListeners = () => {

    document.querySelector('.zoom .slider').addEventListener('change', event => {

        let materialThumbnails = document.querySelectorAll('.material .thumbnail')
        let zoomValue = parseInt(event.currentTarget.value)

        materialThumbnails.forEach(materialThumbnail => {
            materialThumbnail.width = zoomValue
            materialThumbnail.height = zoomValue
        })

        sketchup.setZoomValue(zoomValue)

    })

    document.querySelector('.zoom .slider').dispatchEvent(new Event('change'))

    document.querySelector('.zoom .in.icon').addEventListener('click', _event => {

        let zoomSlider = document.querySelector('.zoom .slider')
        let zoomValue = parseInt(zoomSlider.value)

        if ( zoomValue === parseInt(zoomSlider.max) ) {
            return
        }

        zoomValue += parseInt(zoomSlider.step)
        zoomSlider.value = zoomValue

        zoomSlider.dispatchEvent(new Event('change'))

    })

    document.querySelector('.zoom .out.icon').addEventListener('click', event => {

        let zoomSlider = document.querySelector('.zoom .slider')
        let zoomValue = parseInt(zoomSlider.value)

        if ( zoomValue === parseInt(zoomSlider.min) ) {
            return
        }

        zoomValue -= parseInt(zoomSlider.step)
        zoomSlider.value = zoomValue

        zoomSlider.dispatchEvent(new Event('change'))

    })

    document.querySelector('.eye.icon').addEventListener('click', _event => {
        MaterialBrowser.showSettingsOverlay()
    })

    document.querySelector('.display-name').addEventListener('change', event => {

        let displayName = event.currentTarget.checked
        let materialNames = document.querySelectorAll('.material .name')

        if ( displayName ) {

            materialNames.forEach(materialName => {
                materialName.classList.add('displayed')
            })

        } else {

            materialNames.forEach(materialName => {
                materialName.classList.remove('displayed')
            })

        }

        MaterialBrowser.hideSettingsOverlay()

        sketchup.setDisplayName(displayName)

    })

    document.querySelector('.display-name').dispatchEvent(new Event('change'))

    document.querySelector('.display-source').addEventListener('change', event => {

        let displaySource = event.currentTarget.checked
        let materialSourceLogos = document.querySelectorAll('.material .source-logo')

        if ( displaySource ) {

            materialSourceLogos.forEach(materialSourceLogo => {
                materialSourceLogo.classList.add('displayed')
            })

        } else {

            materialSourceLogos.forEach(materialSourceLogo => {
                materialSourceLogo.classList.remove('displayed')
            })

        }

        MaterialBrowser.hideSettingsOverlay()

        sketchup.setDisplaySource(displaySource)

    })

    document.querySelector('.display-source').dispatchEvent(new Event('change'))

    document.querySelector('.display-only-model').addEventListener('change', event => {

        MaterialBrowser.hideSettingsOverlay()
        sketchup.setDisplayOnlyModel(event.currentTarget.checked)

    })

    document.querySelector('#settings .close').addEventListener('click', _event => {
        MaterialBrowser.hideSettingsOverlay()
    })

    document.querySelector('.skm-folder.icon').addEventListener('click', _event => {
        sketchup.setCustomSKMPath()
    })

    document.querySelector('.heart.icon').addEventListener('click', _event => {
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

    document.querySelector('.filter-by-type').addEventListener('change', event => {

        let typeFilterValue = event.currentTarget.value

        if ( typeFilterValue === 'all' ) {

            let materials = document.querySelectorAll('.material')

            materials.forEach(material => {
                material.classList.remove('hidden')
            })

        } else {

            let materialsToDisplay = document.querySelectorAll(
                '.material[data-type="' + typeFilterValue + '"]'
            )
            let materialsToHide = document.querySelectorAll(
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

    })

    document.querySelector('.filter-by-type').dispatchEvent(new Event('change'))

    document.querySelectorAll('.model-material.thumbnail').forEach(modelMaterialThumbnail => {
        
        modelMaterialThumbnail.addEventListener('click', event => {
            sketchup.selectModelMaterial(event.currentTarget.dataset.name)
        })

    })

    document.querySelectorAll('.skm-file.thumbnail').forEach(skmFileThumbnail => {
        
        skmFileThumbnail.addEventListener('click', event => {
            sketchup.selectSKMFile(event.currentTarget.dataset.path)
        })

    })

    document.querySelectorAll('.ph-texture.thumbnail').forEach(phTextureThumbnail => {
        
        phTextureThumbnail.addEventListener('click', event => {
            sketchup.selectPolyHavenTexture(event.currentTarget.dataset.slug)
        })

    })

    // In case backend crashes, we provide user a way to hide loading screen manually.
    document.querySelector('#loading').addEventListener('click', _event => {
        MaterialBrowser.hideLoadingScreen()
    })

    document.querySelectorAll('.material .source-logo').forEach(materialSourceLogo => {

        if ( materialSourceLogo.hasAttribute('data-source-url') ) {
            materialSourceLogo.addEventListener('click', event => {
                sketchup.openURL(event.currentTarget.dataset.sourceUrl)
            })
        }

    })

}

// When document is ready:
document.addEventListener('DOMContentLoaded', _event => {

    // Make material list searchable
    new List('materials', options = {
        valueNames: ['name'] // by name.
    })

    // Enable only tooltip on icons with title attribute.
    // FIXME: On thumbnails titles, it slowdowns UI a lot.
    new Drooltip({
        element: '.icon[title]',
        position: 'right',
    })

    MaterialBrowser.addEventListeners()

})
