/**
 * Material Browser (MBR) UI.
 *
 * @package MBR extension for SketchUp
 *
 * @copyright © 2021 Samuel Tallet
 *
 * @licence GNU General Public License 3.0
 */

/**
 * Material Browser plugin namespace.
 */
MaterialBrowser = {}

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
        
        document.querySelector('#materials').classList.add('hidden')
        document.querySelector('.overlay').classList.add('displayed')

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

        document.querySelector('.overlay').classList.remove('displayed')
        document.querySelector('#materials').classList.remove('hidden')

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

        document.querySelector('.overlay').classList.remove('displayed')
        document.querySelector('#materials').classList.remove('hidden')

        sketchup.setDisplaySource(displaySource)

    })

    document.querySelector('.display-source').dispatchEvent(new Event('change'))

    document.querySelector('.display-only-model').addEventListener('change', event => {

        document.querySelector('.overlay').classList.remove('displayed')
        document.querySelector('#materials').classList.remove('hidden')

        sketchup.setDisplayOnlyModel(event.currentTarget.checked)

    })

    document.querySelector('.close-overlay').addEventListener('click', _event => {

        document.querySelector('.overlay').classList.remove('displayed')
        document.querySelector('#materials').classList.remove('hidden')
        
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

    document.querySelectorAll('.th-material.thumbnail').forEach(thMaterialThumbnail => {
        
        thMaterialThumbnail.addEventListener('click', event => {
            sketchup.selectTHMaterial({
                texture_url: event.currentTarget.dataset.textureUrl,
                texture_size: event.currentTarget.dataset.textureSize,
                display_name: event.currentTarget.dataset.displayName
            })
        })

    })

    document.querySelectorAll('.material .source-logo').forEach(materialSourceLogo => {

        materialSourceLogo.addEventListener('click', event => {
            sketchup.openURL(event.currentTarget.dataset.sourceUrl)
        })

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
