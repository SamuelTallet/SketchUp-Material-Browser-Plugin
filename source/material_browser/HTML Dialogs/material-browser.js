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

    document.querySelector('.display-provider').addEventListener('change', event => {

        let providerLogos = document.querySelectorAll('.provider-logo')

        if (event.currentTarget.checked) {

            providerLogos.forEach(providerLogo => {
                providerLogo.classList.add('displayed')
            })

        } else {

            providerLogos.forEach(providerLogo => {
                providerLogo.classList.remove('displayed')
            })

        }

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
