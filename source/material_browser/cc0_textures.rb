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
require 'fileutils'
require 'open-uri'
require 'json'
require 'material_browser/materials_catalogs'
require 'material_browser/utils'
require 'material_browser/cache'

# Material Browser plugin namespace.
module MaterialBrowser

  # CC0 Textures (CT) is a material source.
  module CC0Textures

    # Base URL of CT site.
    BASE_URL = 'https://cc0textures.com'

    # Gets absolute path to CT materials catalog.
    #
    # @return [String]
    def self.materials_catalog_path
      File.join(MaterialsCatalogs::DIR, 'CC0 Textures')
    end

    # Prepares CT materials catalog.
    #
    # @return [Integer] Count of added CT materials to catalog.
    def self.prepare_materials_catalog

      added_ct_materials_count = 0

      UI.messagebox('Warning: this process can take many minutes. Be patient.')

      ct_materials_part_1 = JSON.parse(URI.open(
        BASE_URL + '/api/v1/full_json?method=SubstanceDesignerPhotoBased&type=PhotoTexturePBR',
        'User-Agent' => MaterialsCatalogs.user_agent
      ).read)

      sleep(1)

      ct_materials_part_2 = JSON.parse(URI.open(
        BASE_URL + '/api/v1/full_json?method=HeightFieldPhotogrammetry&type=PhotoTexturePBR',
        'User-Agent' => MaterialsCatalogs.user_agent
      ).read)

      ct_materials = ct_materials_part_1['Assets'].merge(ct_materials_part_2['Assets'])

      ct_materials.each_key do |ct_material_name|

        ct_material_thumbnail_path = File.join(
          materials_catalog_path,
          ct_material_name + '.jpg'
        )

        next if File.exist?(ct_material_thumbnail_path)

        ct_material_texture_zip_url = BASE_URL +
          '/get?file=' + ct_material_name + '_1K-PNG.zip'

        ct_material_texture_zip_path = File.join(
          Sketchup.temp_dir, 'CC0Textures' + ct_material_name + '.zip'
        )

        sleep(1)

        if Utils.download(
            ct_material_texture_zip_url,
            MaterialsCatalogs.user_agent,
            ct_material_texture_zip_path
          )

          material_texture_path = ct_material_texture_zip_path.sub('.zip', '.png')

          if File.read(ct_material_texture_zip_path) == 'Download Unavailable.'

            File.delete(ct_material_texture_zip_path)
            next

          end

          if Utils.unzip(
              ct_material_texture_zip_path,
              ct_material_name + '_1K_Color.png',
              material_texture_path
            )

            material = Sketchup.active_model.materials.add(ct_material_name)

            material.texture = material_texture_path
            File.delete(material_texture_path)
  
            material.write_thumbnail(ct_material_thumbnail_path, 256)
            added_ct_materials_count = added_ct_materials_count + 1
  
            Sketchup.active_model.materials.remove(material)

          end

        end

        File.delete(ct_material_texture_zip_path) if File.exist?(ct_material_texture_zip_path)

      end

      added_ct_materials_count

    end

    # Catalogs CT materials.
    # Material metadata is stored in `MaterialBrowser::SESSION`.
    def self.catalog_materials

      SESSION[:ct_materials] = []

      Dir.foreach(materials_catalog_path) do |ct_materials_catalog_entry|

        next if ct_materials_catalog_entry == '.' or ct_materials_catalog_entry == '..'

        ct_material_name = ct_materials_catalog_entry.sub('.jpg', '')

        ct_material_texture_zip_url = BASE_URL +
          '/get?file=' + ct_material_name + '_4K-JPG.zip'
        ct_material_source_url = BASE_URL + '/view?id=' + ct_material_name

        ct_material_display_name = ct_material_name.gsub(/[0-9]/, '').split(
          /(?=[A-Z])/
        ).join(' ') + ' ' + ct_material_name.gsub(/[^0-9]/, '')

        ct_material_thumbnail_path = File.join(
          materials_catalog_path, ct_materials_catalog_entry
        )

        SESSION[:ct_materials].push({

          texture_zip_url: ct_material_texture_zip_url,
          source_url: ct_material_source_url,
          name: ct_material_name,
          display_name: ct_material_display_name,
          thumbnail_uri: Utils.path2uri(ct_material_thumbnail_path),
          type: SESSION[:materials_types].from_words(
            Utils.clean_words(ct_material_display_name)
          )

        })

      end

    end

    # Selects a CT material then activates paint tool.
    #
    # @param [Hash] ct_material
    def self.select_material(ct_material)

      Cache.create_materials_textures_dir

      material_texture_path = File.join(
        Cache.materials_textures_path,
        'CC0 Textures ' + ct_material['display_name'] + '.jpg'
      )

      ct_material_texture_zip_path = material_texture_path.sub('.jpg', '.zip')

      if !File.exist?(material_texture_path)

        texture_download_failed_message = TRANSLATE[
          'Material Browser Error: Texture download failed. Check your firewall settings.'
        ]

        Sketchup.status_text = TRANSLATE['Material Browser: Downloading texture...']

        return UI.messagebox(texture_download_failed_message) unless Utils.download(
          ct_material['texture_zip_url'],
          MaterialsCatalogs.user_agent,
          ct_material_texture_zip_path
        )

        Sketchup.status_text = nil

        texture_extracting_failed_message = TRANSLATE[
          'Material Browser Error: Texture extracting failed. Please try again later.'
        ]

        Sketchup.status_text = TRANSLATE['Material Browser: Extracting texture...']

        if Utils.unzip(
            ct_material_texture_zip_path,
            ct_material['name'] + '_4K_Color.jpg',
            material_texture_path
          )

          File.delete(ct_material_texture_zip_path)

          # We also cache downloaded material texture creation date-time.
          File.write(material_texture_path + '.ctime', Time.now.to_i.to_s)

        else

          File.delete(material_texture_path) if File.exist?(material_texture_path)
          File.delete(ct_material_texture_zip_path)

          return UI.messagebox(texture_extracting_failed_message)

        end

        Sketchup.status_text = nil
      
      end

      material = Sketchup.active_model.materials.add(ct_material['display_name'])

      material.texture = material_texture_path
      material.texture.size = 2.m

      Sketchup.active_model.materials.current = material

      Sketchup.send_action('selectPaintTool:')

    end

  end

end
