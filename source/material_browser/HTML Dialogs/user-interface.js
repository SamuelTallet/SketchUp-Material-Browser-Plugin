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
 * Adds zoom slider change event listener.
 */
MaterialBrowser.listenZoomChange = () => {
    document.querySelector('.zoom .slider').addEventListener('change', event => {

        let materialThumbnails = document.querySelectorAll('.material .thumbnail')
        let zoomValue = parseInt(event.currentTarget.value)

        materialThumbnails.forEach(materialThumbnail => {
            materialThumbnail.width = zoomValue
            materialThumbnail.height = zoomValue
        })

        sketchup.setZoomValue(zoomValue)

    })

    // Required to initialize UI.
    document.querySelector('.zoom .slider').dispatchEvent(new Event('change'))
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

        zoomSlider.dispatchEvent(new Event('change'))

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

        zoomSlider.dispatchEvent(new Event('change'))

    })
}

/**
 * Adds eye icon click event listener.
 */
MaterialBrowser.listenEyeClick = () => {
    document.querySelector('.eye.icon').addEventListener('click', _event => {
        MaterialBrowser.showSettingsOverlay()
    })
}

/**
 * Adds display name checkbox change event listener.
 */
MaterialBrowser.listenDisplayNameChange = () => {
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

    // Required to initialize UI.
    document.querySelector('.display-name').dispatchEvent(new Event('change'))
}

/**
 * Adds display source checkbox change event listener.
 */
MaterialBrowser.listenDisplaySourceChange = () => {
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

    // Required to initialize UI.
    document.querySelector('.display-source').dispatchEvent(new Event('change'))
}

/**
 * Adds display only model checkbox change event listener.
 */
MaterialBrowser.listenDisplayOnlyModelChange = () => {
    document.querySelector('.display-only-model').addEventListener('change', event => {

        MaterialBrowser.hideSettingsOverlay()
        sketchup.setDisplayOnlyModel(event.currentTarget.checked)

    })
}

/**
 * Adds settings close button click event listener.
 */
MaterialBrowser.listenSettingsClose = () => {
    document.querySelector('#settings .close').addEventListener('click', _event => {
        MaterialBrowser.hideSettingsOverlay()
    })
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
 * Adds filter by type dropdown change event listener.
 */
MaterialBrowser.listenFilterByTypeChange = () => {
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

    // Required to initialize UI.
    document.querySelector('.filter-by-type').dispatchEvent(new Event('change'))
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
 * Adds source logo click event listeners.
 */
MaterialBrowser.listenSourceLogoClicks = () => {
    document.querySelectorAll('.material .source-logo').forEach(materialSourceLogo => {

        if ( materialSourceLogo.hasAttribute('data-source-url') ) {
            materialSourceLogo.addEventListener('click', event => {
                sketchup.openURL(event.currentTarget.dataset.sourceUrl)
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

    MaterialBrowser.listenEyeClick()
    MaterialBrowser.listenDisplayNameChange()
    MaterialBrowser.listenDisplaySourceChange()
    MaterialBrowser.listenDisplayOnlyModelChange()
    MaterialBrowser.listenSettingsClose()

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

    // Make material list searchable
    const list = new List('materials', options = {
        valueNames: ['name'] // by name.
    })

    MaterialBrowser.addEventListeners()

    list.on('searchComplete', _event => {
        // Fix "thumbnail size desync" issue when user:
        // searches a material then changes thumbnail size then searches again.
        document.querySelector('.zoom .slider').dispatchEvent(new Event('change'))
    })

})
