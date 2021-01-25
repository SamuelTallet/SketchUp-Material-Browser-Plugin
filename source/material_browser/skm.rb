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
require 'material_browser/cache'
require 'material_browser/utils'

# Material Browser plugin namespace.
module MaterialBrowser

  # Manages SketchUp Material (SKM) files.
  module SKM

    # Gets absolute path to stock SKM directory.
    #
    # @raise [RuntimeError]
    #
    # @return [String]
    def self.stock_skm_path

      sketchup_year_version = Sketchup.version.to_i.to_s

      if Sketchup.platform == :platform_osx

        stock_skm_path = File.join(
          '/', 'Applications', 'SketchUp ' + '20' + sketchup_year_version,
          'SketchUp.app', 'Contents', 'Resources', 'Content', 'Materials'
        )

      elsif Sketchup.platform == :platform_win

        stock_skm_path = File.join(
          ENV['PROGRAMDATA'], 'SketchUp', 'SketchUp ' + '20' + sketchup_year_version,
          'SketchUp', 'Materials'
        )
        
      else
        raise 'Unknown operating system.'
      end

    end

    # Gets absolute path to custom SKM directory.
    # Not to be confused with custom SKM path set by user in Material Browser UI.
    #
    # @raise [RuntimeError]
    #
    # @return [String]
    def self.custom_skm_path

      sketchup_year_version = Sketchup.version.to_i.to_s

      if Sketchup.platform == :platform_osx

        custom_skm_path = File.join(
          ENV['HOME'], 'Library', 'Application Support',
          'SketchUp ' + '20' + sketchup_year_version, 'SketchUp', 'Materials'
        )

      elsif Sketchup.platform == :platform_win

        custom_skm_path = File.join(
          ENV['APPDATA'], 'SketchUp', 'SketchUp ' + '20' + sketchup_year_version,
          'SketchUp', 'Materials'
        )
        
      else
        raise 'Unknown operating system.'
      end

    end

    # Extracts thumbnails from SKM files.
    # Material metadata is stored in `MaterialBrowser::SESSION`.
    def self.extract_thumbnails

      SESSION[:skm_files] = []

      Cache.create_materials_thumbnails_dir

      stock_skm_glob_pattern = File.join(stock_skm_path, '**', '*.skm')
      custom_skm_glob_pattern = File.join(custom_skm_path, '**', '*.skm')

      skm_glob_patterns = [stock_skm_glob_pattern, custom_skm_glob_pattern]

      user_custom_skm_path = SESSION[:settings].custom_skm_path

      if Dir.exist?(user_custom_skm_path)

        user_custom_skm_glob_pattern = File.join(user_custom_skm_path, '**', '*.skm')
        skm_glob_patterns.push(user_custom_skm_glob_pattern)

      end
      
      # Fix SKM glob patterns only on Windows.
      if Sketchup.platform == :platform_win

        skm_glob_patterns.each do |skm_glob_pattern|
          skm_glob_pattern.gsub!('\\', '/')
        end
        
      end
      
      skm_file_count = 0

      Sketchup.status_text = TRANSLATE['Material Browser: Extracting thumbnails...']
  
      Dir.glob(skm_glob_patterns).each do |skm_file_path|
  
        skm_file_count = skm_file_count + 1

        skm_display_name = File.basename(skm_file_path).sub('.skm', '').gsub('_', ' ')

        skm_thumbnail_basename = File.basename(skm_file_path).sub(
          '.skm',
          ' #SKM-' + skm_file_count.to_s + '.png'
        )
        skm_thumbnail_path = File.join(
          Cache.materials_thumbnails_path, skm_thumbnail_basename
        )

        # SKM files are ZIP archive files renamed.
        if Utils.unzip(skm_file_path, 'doc_thumbnail.png', skm_thumbnail_path)

          SESSION[:skm_files].push({

            path: skm_file_path,
            display_name: skm_display_name,
            thumbnail_uri: Utils.path2uri(skm_thumbnail_path),
            type: SESSION[:materials_types].from_words(
              Utils.clean_words(skm_display_name)
            )
  
          })

        end

      end

      Sketchup.status_text = nil
  
    end

    # Selects a SKM file then activates paint tool.
    #
    # @param [String] skm_file_path
    def self.select_file(skm_file_path)

      material = Sketchup.active_model.materials.load(skm_file_path)
      Sketchup.active_model.materials.current = material

      Sketchup.send_action('selectPaintTool:')

    end

  end

end
