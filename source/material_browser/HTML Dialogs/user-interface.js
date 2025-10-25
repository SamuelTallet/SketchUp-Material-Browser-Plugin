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
 * Shows display settings overlay.
 */
MaterialBrowser.showDisplaySettings = () => {
    document.querySelector('#materials').classList.add('hidden')
    document.querySelector('#settings').classList.add('displayed')
}

/**
 * Hides display settings overlay.
 */
MaterialBrowser.hideDisplaySettings = () => {
    document.querySelector('#settings').classList.remove('displayed')
    document.querySelector('#materials').classList.remove('hidden')
}

/**
 * Applies "zoom value" setting.
 */
MaterialBrowser.applyZoomValue = () => {
    const zoomValue = parseInt(document.querySelector('.zoom .slider').value)
    const materialThumbnails = document.querySelectorAll('.material .thumbnail')

    materialThumbnails.forEach(materialThumbnail => {
        materialThumbnail.width = zoomValue
        materialThumbnail.height = zoomValue
    })

    sketchup.setZoomValue(zoomValue)
}

/**
 * Adds zoom slider change event listener.
 */
MaterialBrowser.listenZoomChange = () => {
    document.querySelector('.zoom .slider').addEventListener('change', _event => {
        MaterialBrowser.applyZoomValue()
    })
}

/**
 * Adds zoom in button click event listener.
 */
MaterialBrowser.listenZoomInClick = () => {
    document.querySelector('.zoom .in.icon').addEventListener('click', _event => {

        let zoomSlider = document.querySelector('.zoom .slider')
        let zoomValue = parseInt(zoomSlider.value)

        if ( zoomValue === parseInt(zoomSlider.max) ) {
            return
        }

        zoomValue += parseInt(zoomSlider.step)
        zoomSlider.value = zoomValue

        MaterialBrowser.applyZoomValue()

    })
}

/**
 * Adds zoom out button click event listener.
 */
MaterialBrowser.listenZoomOutClick = () => {
    document.querySelector('.zoom .out.icon').addEventListener('click', event => {

        let zoomSlider = document.querySelector('.zoom .slider')
        let zoomValue = parseInt(zoomSlider.value)

        if ( zoomValue === parseInt(zoomSlider.min) ) {
            return
        }

        zoomValue -= parseInt(zoomSlider.step)
        zoomSlider.value = zoomValue

        MaterialBrowser.applyZoomValue()

    })
}

/**
 * Adds display settings open icon click event listener.
 */
MaterialBrowser.listenDisplaySettingsOpen = () => {
    document.querySelector('.eye.icon').addEventListener('click', _event => {
        MaterialBrowser.showDisplaySettings()
    })
}

/**
 * Adds display settings commit button click event listener.
 */
MaterialBrowser.listenDisplaySettingsCommit = () => {
    document.querySelector('#settings .commit').addEventListener('click', _event => {
        MaterialBrowser.hideDisplaySettings()
        MaterialBrowser.applyDisplaySettings()
    })
}

/**
 * Applies "display name" setting.
 */
MaterialBrowser.applyDisplayName = () => {
    const displayName = document.querySelector('.display-name').checked
    const materialNames = document.querySelectorAll('.material .name')

    materialNames.forEach(materialName => {
        materialName.classList.toggle('displayed', displayName)
    })

    sketchup.setDisplayName(displayName)
}

/**
 * Applies display settings.
 */
MaterialBrowser.applyDisplaySettings = () => {
    MaterialBrowser.applyDisplayName()
    // TODO: Implement sources_to_display setting.
}

/**
 * Adds SKM folder icon click event listener.
 */
MaterialBrowser.listenSKMFolderClick = () => {
    document.querySelector('.skm-folder.icon').addEventListener('click', _event => {
        sketchup.setCustomSKMPath()
    })
}

/**
 * Adds help icon click event listener.
 */
MaterialBrowser.listenHelpClick = () => {
    document.querySelector('.help.icon').addEventListener('click', _event => {
        sketchup.openURL(MaterialBrowser.HELP_URL)
    })
}

/**
 * Adds heart icon click event listener.
 */
MaterialBrowser.listenHeartClick = () => {
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
}

/**
 * Applies "type filter value" setting.
 */
MaterialBrowser.applyTypeFilterValue = () => {
    const typeFilterValue = document.querySelector('.filter-by-type').value

    if ( typeFilterValue === 'all' ) {
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
    document.querySelector('.filter-by-type').addEventListener('change', _event => {
        MaterialBrowser.applyTypeFilterValue()
    })
}

/**
 * Adds model material thumbnail click event listeners.
 */
MaterialBrowser.listenModelMaterialClicks = () => {
    document.querySelectorAll('.model-material.thumbnail').forEach(modelMaterialThumbnail => {
        
        modelMaterialThumbnail.addEventListener('click', event => {
            sketchup.selectModelMaterial(event.currentTarget.dataset.name)
        })

    })
}

/**
 * Adds SKM file thumbnail click event listeners.
 */
MaterialBrowser.listenSKMFileClicks = () => {
    document.querySelectorAll('.skm-file.thumbnail').forEach(skmFileThumbnail => {
        
        skmFileThumbnail.addEventListener('click', event => {
            sketchup.selectSKMFile(event.currentTarget.dataset.path)
        })

    })
}

/**
 * Adds PolyHaven texture thumbnail click event listeners.
 */
MaterialBrowser.listenPolyHavenTextureClicks = () => {
    document.querySelectorAll('.ph-texture.thumbnail').forEach(phTextureThumbnail => {
        
        phTextureThumbnail.addEventListener('click', event => {
            sketchup.selectPolyHavenTexture(event.currentTarget.dataset.slug)
        })

    })
}

/**
 * Adds loading screen click event listener.
 *
 * In case backend crashes, we provide user a way to hide loading screen.
 */
MaterialBrowser.listenLoadingScreenClick = () => {
    document.querySelector('#loading').addEventListener('click', _event => {
        MaterialBrowser.hideLoadingScreen()
    })
}

/**
 * Shows source logos.
 */
MaterialBrowser.showSourceLogos = () => {
    const sourceLogos = document.querySelectorAll('.material .source-logo')
    sourceLogos.forEach(sourceLogo => {
        sourceLogo.classList.add('displayed')
    })
}

/**
 * Adds source logo click event listeners.
 */
MaterialBrowser.listenSourceLogoClicks = () => {
    document.querySelectorAll('.material .source-logo').forEach(materialSourceLogo => {

        if ( materialSourceLogo.hasAttribute('data-url') ) {
            materialSourceLogo.addEventListener('click', event => {
                sketchup.openURL(event.currentTarget.dataset.url)
            })
        }

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

    MaterialBrowser.listenModelMaterialClicks()
    MaterialBrowser.listenSKMFileClicks()
    MaterialBrowser.listenPolyHavenTextureClicks()
    MaterialBrowser.listenLoadingScreenClick()

    MaterialBrowser.listenSourceLogoClicks()

}

// When document is ready:
document.addEventListener('DOMContentLoaded', _event => {

    // Restore last known UI state.
    MaterialBrowser.applyZoomValue()
    MaterialBrowser.applyTypeFilterValue()
    MaterialBrowser.applyDisplayName()
    MaterialBrowser.showSourceLogos()

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
