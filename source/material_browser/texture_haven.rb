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
require 'rehtml'
require 'rexml/xpath'
require 'material_browser/materials_catalogs'
require 'material_browser/utils'
require 'material_browser/cache'

# Material Browser plugin namespace.
module MaterialBrowser

  # Texture Haven (TH) is a material source.
  module TextureHaven

    # Base URL of TH site.
    BASE_URL = 'https://texturehaven.com'

    # Gets absolute path to TH materials catalog.
    #
    # @return [String]
    def self.materials_catalog_path
      File.join(MaterialsCatalogs::DIR, 'Texture Haven')
    end

    # Prepares TH materials catalog.
    #
    # @return [Integer] Count of added TH materials to catalog.
    def self.prepare_materials_catalog

      added_th_materials_count = 0

      UI.messagebox('Warning: this process can take many minutes. Be patient.')

      th_materials_rexml_document = REHTML.to_rexml(
        URI.open(
          BASE_URL + '/textures/',
          'User-Agent' => MaterialsCatalogs.user_agent
        ).read
      )

      th_materials_sources_urls = REXML::XPath.match(
        th_materials_rexml_document, '//div[@id="item-grid"]/a/@href'
      )

      th_materials_sources_urls.each do |th_material_source_url|

        sleep(1)

        th_material_name = th_material_source_url.value.to_s.sub('/tex/?t=', '')

        th_material_source_html = URI.open(
          BASE_URL + th_material_source_url.value.to_s,
          'User-Agent' => MaterialsCatalogs.user_agent
        ).read

        th_material_texture_size = 2.0 # m

        if th_material_source_html_match = th_material_source_html.match(
            /<li title='Real-world scale: (.+)'><b><i class='material-icons'>accessibility/
          )

          th_material_texture_scale = th_material_source_html_match.captures.first.downcase

          th_material_texture_size = th_material_texture_scale\
            .split('x').first.gsub(/[^0-9\.]/, '').to_f

          if th_material_texture_scale.include?('cm')
            th_material_texture_size = th_material_texture_size / 100.0
          end

        end

        th_material_thumbnail_path = File.join(
          materials_catalog_path,
          th_material_name + '-' + th_material_texture_size.to_s + '.jpg'
        )

        next if File.exist?(th_material_thumbnail_path)

        th_material_texture_url = BASE_URL + '/files/textures/png/1k/' +
          th_material_name + '/' + th_material_name + '_diff_1k.png'

        material_texture_path = File.join(
          Sketchup.temp_dir, 'texture_haven-' + th_material_name + '.png'
        )

        if Utils.download(
            th_material_texture_url, MaterialsCatalogs.user_agent, material_texture_path
          )

          material = Sketchup.active_model.materials.add(th_material_name)

          material.texture = material_texture_path

          material.write_thumbnail(th_material_thumbnail_path, 256)
          added_th_materials_count = added_th_materials_count + 1

          Sketchup.active_model.materials.remove(material)

        end

        File.delete(material_texture_path) if File.exist?(material_texture_path)

      end

      added_th_materials_count

    end

    # Catalogs TH materials.
    # Material metadata is stored in `MaterialBrowser::SESSION`.
    def self.catalog_materials

      SESSION[:th_materials] = []

      Dir.foreach(materials_catalog_path) do |th_materials_catalog_entry|

        next if th_materials_catalog_entry == '.' or th_materials_catalog_entry == '..'
        
        th_material_metadata = th_materials_catalog_entry.sub('.jpg', '').split('-')
        th_material_name = th_material_metadata[0]
        th_material_texture_size = th_material_metadata[1].to_f

        th_material_texture_url = BASE_URL + '/files/textures/jpg/4k/' +
          th_material_name + '/' + th_material_name + '_diff_4k.jpg'
        th_material_source_url = BASE_URL + '/tex/?t=' + th_material_name

        th_material_display_name = Utils.ucwords(th_material_name.gsub('_', ' '))

        th_material_thumbnail_path = File.join(
          materials_catalog_path, th_materials_catalog_entry
        )

        SESSION[:th_materials].push({

          texture_url: th_material_texture_url,
          texture_size: th_material_texture_size,
          source_url: th_material_source_url,
          display_name: th_material_display_name,
          thumbnail_uri: Utils.path2uri(th_material_thumbnail_path),
          type: SESSION[:materials_types].from_words(
            Utils.clean_words(th_material_display_name)
          )

        })

      end

    end

    # Selects a TH material then activates paint tool.
    #
    # @param [Hash] th_material
    def self.select_material(th_material)

      Cache.create_materials_textures_dir

      material_texture_path = File.join(
        Cache.materials_textures_path,
        'Texture Haven ' + th_material['display_name'] + '.jpg'
      )

      if !File.exist?(material_texture_path)

        texture_download_failed_message = TRANSLATE[
          'Material Browser Error: Texture download failed. Check your firewall settings.'
        ]

        Sketchup.status_text = TRANSLATE['Material Browser: Downloading texture...']

        return UI.messagebox(texture_download_failed_message) unless Utils.download(
          th_material['texture_url'], MaterialsCatalogs.user_agent, material_texture_path
        )

        Sketchup.status_text = nil

        # We also cache downloaded material texture creation date-time.
        File.write(material_texture_path + '.ctime', Time.now.to_i.to_s)
      
      end

      material = Sketchup.active_model.materials.add(th_material['display_name'])

      material.texture = material_texture_path
      material.texture.size = th_material['texture_size'].to_f.m

      Sketchup.active_model.materials.current = material

      Sketchup.send_action('selectPaintTool:')

    end

  end

end
