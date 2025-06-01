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

require 'zlib'
require 'fileutils'
require 'sketchup'
require 'material_browser/utils'
require 'material_browser/materials_types'

# Material Browser plugin namespace.
module MaterialBrowser

  # Manages SketchUp Material (SKM) files.
  module SKM

    # Absolute path to stock SKM directory.
    # This is where materials shipped with SketchUp are.
    #
    # @raise [RuntimeError]
    #
    # @return [String]
    def self.stock_path
      sketchup_year_version = Sketchup.version.to_i.to_s

      if Sketchup.platform == :platform_osx
        File.join(
          '/', 'Applications', 'SketchUp ' + '20' + sketchup_year_version,
          'SketchUp.app', 'Contents', 'Resources', 'Content', 'Materials'
        )

      elsif Sketchup.platform == :platform_win
        File.join(
          ENV['PROGRAMDATA'], 'SketchUp', 'SketchUp ' + '20' + sketchup_year_version,
          'SketchUp', 'Materials'
        )
        
      else
        raise 'Unknown operating system.'
      end
    end

    # Absolute path to custom SKM directory.
    # Not to be confused with custom SKM path set by user in Material Browser UI.
    #
    # @raise [RuntimeError]
    #
    # @return [String]
    def self.custom_path
      sketchup_year_version = Sketchup.version.to_i.to_s

      if Sketchup.platform == :platform_osx
        File.join(
          ENV['HOME'], 'Library', 'Application Support',
          'SketchUp ' + '20' + sketchup_year_version, 'SketchUp', 'Materials'
        )

      elsif Sketchup.platform == :platform_win
        File.join(
          ENV['APPDATA'], 'SketchUp', 'SketchUp ' + '20' + sketchup_year_version,
          'SketchUp', 'Materials'
        )

      else
        raise 'Unknown operating system.'
      end
    end

    # Absolute path to SKM thumbnails directory.
    #
    # @return [String]
    def self.thumbnails_path
      # If several versions of SketchUp are installed:
      # we don't want, for example, to remove SKM thumbs for all versions.
      # It'd be a waste of time to regenerate them...
      File.join(Sketchup.temp_dir, "SketchUp 20#{Sketchup.version.to_i} MBR Plugin SKM Thumbs")
    end

    # Removes SKM thumbnails directory.
    def self.remove_thumbnails_dir
      FileUtils.remove_dir(thumbnails_path) if Dir.exist?(thumbnails_path)
    end

    # Creates SKM thumbnails directory.
    def self.create_thumbnails_dir
      FileUtils.mkdir_p(thumbnails_path) unless Dir.exist?(thumbnails_path)
    end

    # Extracts thumbnails from SKM files.
    # Material metadata is stored in `MaterialBrowser::SESSION`.
    def self.extract_thumbnails

      SESSION[:skm_files] = []

      create_thumbnails_dir

      stock_skm_glob_pattern = File.join(stock_path, '**', '*.skm')
      custom_skm_glob_pattern = File.join(custom_path, '**', '*.skm')

      skm_glob_patterns = [stock_skm_glob_pattern, custom_skm_glob_pattern]

      user_custom_skm_path = SESSION[:settings].custom_skm_path

      if Dir.exist?(user_custom_skm_path)
        user_custom_skm_glob_pattern = File.join(user_custom_skm_path, '**', '*.skm')
        skm_glob_patterns.push(user_custom_skm_glob_pattern)
      end

      # Fixes SKM glob patterns only on Windows.
      if Sketchup.platform == :platform_win
        skm_glob_patterns.each do |skm_glob_pattern|
          skm_glob_pattern.gsub!('\\', '/')
        end
      end

      Sketchup.status_text = TRANSLATE['Material Browser: Extracting thumbnails...']

      Dir.glob(skm_glob_patterns).each do |skm_file_path|
        thumbnail_basename = Zlib.crc32(skm_file_path).to_s
        thumbnail_basename += '@' + File.mtime(skm_file_path).to_i.to_s + '.png'

        thumbnail_path = File.join(thumbnails_path, thumbnail_basename)
        thumbnail_available = File.exist?(thumbnail_path)

        # To index SKM files faster:
        # We don't re-extract thumbnails of SKM files having same path and modification time.
        # This isn't perfect... There are cases where a thumbnail shouldn't be re-extracted:
        # - A SKM file with no intrinsic change have been moved/renamed.
        # - A SKM file contents has been modified in a way that didn't affect its thumbnail.
        # But I think it's less bad than displaying outdated thumbnails, more user-friendly.
        # In an ideal world, SKM files are deep-compared...
        unless thumbnail_available
          thumbnail_available = Utils.unzip(skm_file_path, 'doc_thumbnail.png', thumbnail_path)
          # SKM files are ZIP files.

          unless thumbnail_available
            puts "Material Browser: Failed to extract thumbnail from #{skm_file_path}."
          end
        end

        if thumbnail_available
          skm_display_name = File.basename(skm_file_path).sub('.skm', '').gsub('_', ' ')

          SESSION[:skm_files].push({
            path: skm_file_path,
            display_name: skm_display_name,
            thumbnail_uri: Utils.path2uri(thumbnail_path),
            type: MaterialsTypes.get.from_words(Utils.clean_words(skm_display_name))
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
