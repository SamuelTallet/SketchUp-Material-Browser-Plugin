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
        let zoomValue = event.currentTarget.value

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

    document.querySelector('.filter.icon').addEventListener('click', _event => {
        
        document.querySelector('#materials').classList.add('hidden')
        document.querySelector('.filters-overlay').classList.add('displayed')

    })

    document.querySelector('.filter-by-source').addEventListener('change', event => {

        let sourceFilterValue = event.currentTarget.value

        if ( sourceFilterValue === 'all' ) {

            let materials = document.querySelectorAll('.material')

            materials.forEach(material => {
                material.classList.remove('hidden')
            })

        } else {

            let materialsToDisplay = document.querySelectorAll(
                '.material[data-source="' + sourceFilterValue + '"]'
            )
            let materialsToHide = document.querySelectorAll(
                '.material:not([data-source="' + sourceFilterValue + '"])'
            )
    
            materialsToDisplay.forEach(materialToDisplay => {
                materialToDisplay.classList.remove('hidden')
            })
    
            materialsToHide.forEach(materialToHide => {
                materialToHide.classList.add('hidden')
            })

        }

        sketchup.setSourceFilterValue(sourceFilterValue)

    })

    document.querySelector('.filter-by-source').dispatchEvent(new Event('change'))

    document.querySelector('.validate-filters').addEventListener('click', _event => {

        document.querySelector('.filters-overlay').classList.remove('displayed')
        document.querySelector('#materials').classList.remove('hidden')
        
    })

    document.querySelector('.skm-folder.icon').addEventListener('click', _event => {
        sketchup.setCustomSKMPath()
    })

    document.querySelector('.display').addEventListener('change', event => {

        let displayValue = event.currentTarget.value
        let materialNames = document.querySelectorAll('.material .name')
        let materialSourceLogos = document.querySelectorAll('.material .source-logo')
        
        switch (displayValue) {

            case 'nothing_more':

                materialNames.forEach(materialName => {
                    materialName.classList.remove('displayed')
                })

                materialSourceLogos.forEach(materialSourceLogo => {
                    materialSourceLogo.classList.remove('displayed')
                })
                
                break;

            case 'name':

                materialNames.forEach(materialName => {
                    materialName.classList.add('displayed')
                })

                materialSourceLogos.forEach(materialSourceLogo => {
                    materialSourceLogo.classList.remove('displayed')
                })

                break;

            case 'source':

                materialNames.forEach(materialName => {
                    materialName.classList.remove('displayed')
                })

                materialSourceLogos.forEach(materialSourceLogo => {
                    materialSourceLogo.classList.add('displayed')
                })

                break;

            case 'name_and_source':

                materialNames.forEach(materialName => {
                    materialName.classList.add('displayed')
                })

                materialSourceLogos.forEach(materialSourceLogo => {
                    materialSourceLogo.classList.add('displayed')
                })

                break;

        }

        sketchup.setDisplayValue(displayValue)

    })

    document.querySelector('.display').dispatchEvent(new Event('change'))

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

}

// When document is ready:
document.addEventListener('DOMContentLoaded', _event => {

    // Make material list searchable
    new List('materials', options = {
        valueNames: ['name'] // by name.
    })

    MaterialBrowser.addEventListeners()

})
