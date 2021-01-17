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
        let materialThumbnailsZoomValue = event.currentTarget.value

        materialThumbnails.forEach(materialThumbnail => {
            materialThumbnail.width = materialThumbnailsZoomValue
            materialThumbnail.height = materialThumbnailsZoomValue
        })

        sketchup.setMaterialThumbnailsZoom(materialThumbnailsZoomValue)

    })

    document.querySelector('.zoom .slider').dispatchEvent(new Event('change'))

    document.querySelector('.zoom .in.icon').addEventListener('click', event => {

        let materialThumbnailsZoomSlider = document.querySelector('.zoom .slider')
        let materialThumbnailsZoomValue = parseInt(materialThumbnailsZoomSlider.value)

        if ( materialThumbnailsZoomValue === parseInt(materialThumbnailsZoomSlider.max) ) {
            return
        }

        materialThumbnailsZoomValue += parseInt(materialThumbnailsZoomSlider.step)
        materialThumbnailsZoomSlider.value = materialThumbnailsZoomValue

        materialThumbnailsZoomSlider.dispatchEvent(new Event('change'))

    })

    document.querySelector('.zoom .out.icon').addEventListener('click', event => {

        let materialThumbnailsZoomSlider = document.querySelector('.zoom .slider')
        let materialThumbnailsZoomValue = parseInt(materialThumbnailsZoomSlider.value)

        if ( materialThumbnailsZoomValue === parseInt(materialThumbnailsZoomSlider.min) ) {
            return
        }

        materialThumbnailsZoomValue -= parseInt(materialThumbnailsZoomSlider.step)
        materialThumbnailsZoomSlider.value = materialThumbnailsZoomValue

        materialThumbnailsZoomSlider.dispatchEvent(new Event('change'))

    })

    document.querySelector('.display').addEventListener('change', event => {

        let materialNames = document.querySelectorAll('.material .name')
        let materialProviderLogos = document.querySelectorAll('.material .provider-logo')
        let materialThumbnailsDisplayValue = event.currentTarget.value

        switch (materialThumbnailsDisplayValue) {

            case 'nothing_more':

                materialNames.forEach(materialName => {
                    materialName.classList.remove('displayed')
                })

                materialProviderLogos.forEach(materialProviderLogo => {
                    materialProviderLogo.classList.remove('displayed')
                })
                
                break;

            case 'name':

                materialNames.forEach(materialName => {
                    materialName.classList.add('displayed')
                })

                materialProviderLogos.forEach(materialProviderLogo => {
                    materialProviderLogo.classList.remove('displayed')
                })

                break;

            case 'provider':

                materialNames.forEach(materialName => {
                    materialName.classList.remove('displayed')
                })

                materialProviderLogos.forEach(materialProviderLogo => {
                    materialProviderLogo.classList.add('displayed')
                })

                break;

            case 'name_and_provider':

                materialNames.forEach(materialName => {
                    materialName.classList.add('displayed')
                })

                materialProviderLogos.forEach(materialProviderLogo => {
                    materialProviderLogo.classList.add('displayed')
                })

                break;

        }

        sketchup.setMaterialThumbnailsDisplay(materialThumbnailsDisplayValue)

    })

    document.querySelector('.display').dispatchEvent(new Event('change'))

    document.querySelector('.skm-folder.icon').addEventListener('click', _event => {
        sketchup.setCustomSKMPath()
    })

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
