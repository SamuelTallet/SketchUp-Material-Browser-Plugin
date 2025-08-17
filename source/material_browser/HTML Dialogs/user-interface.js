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
 * Shows loading screen.
 */
MaterialBrowser.showLoadingScreen = () => {
    document.querySelector('#materials').classList.add('hidden')
    document.querySelector('.loading-screen').classList.add('displayed')
}

/**
 * Hides loading screen.
 */
MaterialBrowser.hideLoadingScreen = () => {
    document.querySelector('.loading-screen').classList.remove('displayed')
    document.querySelector('#materials').classList.remove('hidden')
}

/**
 * Shows settings overlay.
 */
MaterialBrowser.showSettingsOverlay = () => {
    document.querySelector('#materials').classList.add('hidden')
    document.querySelector('.overlay').classList.add('displayed')
}

/**
 * Hides settings overlay.
 */
MaterialBrowser.hideSettingsOverlay = () => {
    document.querySelector('.overlay').classList.remove('displayed')
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

    document.querySelector('.close-overlay').addEventListener('click', _event => {
        MaterialBrowser.hideSettingsOverlay()
    })

    document.querySelector('.skm-folder.icon').addEventListener('click', _event => {
        sketchup.setCustomSKMPath()
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
            MaterialBrowser.showLoadingScreen()
            sketchup.selectPolyHavenTexture(event.currentTarget.dataset.slug)
        })

    })

    document.querySelector('.loading-screen').addEventListener('click', _event => {
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

    MaterialBrowser.addEventListeners()

})
