# Material Browser (MBR) extension for SketchUp 2017 or newer.
# Copyright: © 2021 Samuel Tallet <samuel.tallet arobase gmail.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3.0 of the License, or
# (at your option) any later version.
# 
# If you release a modified version of this program TO THE PUBLIC,
# the GPL requires you to MAKE THE MODIFIED SOURCE CODE AVAILABLE
# to the program's users, UNDER THE GPL.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# Get a copy of the GPL here: https://www.gnu.org/licenses/gpl.html

raise 'The MBR plugin requires at least Ruby 2.2.0 or SketchUp 2017.'\
  unless RUBY_VERSION.to_f >= 2.2 # SketchUp 2017 includes Ruby 2.2.4.

require 'sketchup'
require 'material_browser/material_catalogs'
require 'material_browser/utils'

# Material Browser plugin namespace.
module MaterialBrowser

  # Texture Haven is a material source.
  module TextureHaven

    # Base URL of Texture Haven site.
    BASE_URL = 'https://texturehaven.com'

    # Catalogs Texture Haven (TH) materials.
    # Material metadata is stored in `MaterialBrowser::SESSION`.
    def self.catalog_materials

      SESSION[:th_materials] = []

      th_material_thumbnails_path = File.join(MaterialCatalogs::DIR, 'Texture Haven')

      Dir.foreach(th_material_thumbnails_path) do |th_material_thumbnail_basename|

        next if th_material_thumbnail_basename == '.' or th_material_thumbnail_basename == '..'
        
        th_material_metadata = th_material_thumbnail_basename.sub('.jpg', '').split('-')
        th_material_name = th_material_metadata[0]
        th_material_texture_size = th_material_metadata[1].to_f

        th_material_texture_url = BASE_URL + '/files/textures/jpg/4k/' +
        th_material_name + '/' + th_material_name + '_diff_4k.jpg'

        th_material_display_name = Utils.ucwords(th_material_name.gsub('_', ' '))

        th_material_thumbnail_path = File.join(
          th_material_thumbnails_path, th_material_thumbnail_basename
        )

        SESSION[:th_materials].push({

          texture_url: th_material_texture_url,
          texture_size: th_material_texture_size,
          display_name: th_material_display_name,
          thumbnail_uri: Utils.path2uri(th_material_thumbnail_path)

        })

      end

    end

    # Selects a Texture Haven material then activates paint tool.
    #
    # @param [Hash] th_material
    def self.select_material(th_material)

      material_texture_path = File.join(
        Sketchup.temp_dir, 'Texture Haven ' + th_material['display_name'] + '.jpg'
      )

      Sketchup.status_text = TRANSLATE['Material Browser: Downloading texture...']

      texture_download_failed_message = TRANSLATE[
        'Material Browser Error: Texture download failed. Check your firewall settings.'
      ]

      return UI.messagebox(texture_download_failed_message) unless Utils.download(
        th_material['texture_url'], MaterialCatalogs.user_agent, material_texture_path
      )

      Sketchup.status_text = nil

      material = Sketchup.active_model.materials.add(th_material['display_name'])

      material.texture = material_texture_path
      File.delete(material_texture_path)
      material.texture.size = th_material['texture_size'].to_f.m

      Sketchup.active_model.materials.current = material

      Sketchup.send_action('selectPaintTool:')

    end

  end

end
