# Material Browser (MBR) extension for SketchUp 2017 or newer.
# Copyright: © 2025 Samuel Tallet <samuel.tallet arobase gmail.com>
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

require 'fileutils'
require 'sketchup'
require 'material_browser/utils'
require 'material_browser/materials_types'

# Material Browser plugin namespace.
module MaterialBrowser

  # Manages SketchUp active model.
  module Model

    # Gets absolute path to active model's materials thumbnails directory.
    #
    # @return [String]
    def self.materials_thumbnails_path
      # User can open Material Browser plugin in different SketchUp versions at the same time.
      # Better isolate this thumbnails directory for each...
      File.join(Sketchup.temp_dir, "SketchUp 20#{Sketchup.version.to_i} MBR Plugin AM Thumbs")
    end

    # Removes active model's materials thumbnails directory.
    def self.remove_materials_thumbnails_dir
      FileUtils.remove_dir(materials_thumbnails_path) if Dir.exist?(materials_thumbnails_path)
    end

    # Creates active model's materials thumbnails directory.
    def self.create_materials_thumbnails_dir
      FileUtils.mkdir_p(materials_thumbnails_path) unless Dir.exist?(materials_thumbnails_path)
    end

    # Exports materials thumbnails of active model.
    # Material metadata is stored in `MaterialBrowser::SESSION`.
    def self.export_materials_thumbnails

      SESSION[:model_materials] = []

      create_materials_thumbnails_dir

      Sketchup.status_text = TRANSLATE['Material Browser: Exporting thumbnails...']

      materials_count = 0

      Sketchup.active_model.materials.each do |material|

        materials_count = materials_count + 1

        # To stay consistent with display of SKM files,
        # model materials will be displayed in english.
        material_display_name = material.name.gsub(/\[|\]/, '').gsub('_', ' ')

        material_thumbnail_basename = materials_count.to_s + '.jpg'
        material_thumbnail_path = File.join(
          materials_thumbnails_path, material_thumbnail_basename
        )

        material_thumbnail_size = 256

        # Assumes a color by default.
        unless material.texture.nil?

          material_texture_size = [
            material.texture.image_height, material.texture.image_width
          ].min
  
          # Material thumbnail size can't exceed texture size.
          if material_texture_size <= 256
            material_thumbnail_size = material_texture_size - 1
          end

        end

        # Note this method overwrites files having same name.
        material.write_thumbnail(material_thumbnail_path, material_thumbnail_size)

        SESSION[:model_materials].push({
          name: material.name,
          display_name: material_display_name,
          thumbnail_uri: Utils.path2uri(material_thumbnail_path),
          type: MaterialsTypes.get.from_words(Utils.clean_words(material_display_name))
        })

      end

      Sketchup.status_text = nil

    end

    # Selects a material of active model then activates paint tool.
    #
    # @param [String] model_material_name
    def self.select_material(model_material_name)

      material = Sketchup.active_model.materials[model_material_name]
      Sketchup.active_model.materials.current = material

      Sketchup.send_action('selectPaintTool:')

    end

  end

end
