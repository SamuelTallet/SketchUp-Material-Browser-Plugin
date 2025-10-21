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
require 'material_browser/settings'
require 'material_browser/unzip'
require 'material_browser/path'
require 'material_browser/words'
require 'material_browser/materials_types'

# Material Browser plugin namespace.
module MaterialBrowser

  # Manages SketchUp Material (SKM) files.
  module SKM

    # SKM files metadata.
    @@files = {
      :builtin => [],
      :profile => [],
      :custom => []
    }

    # Metadata of SKM files.
    #
    # @return [Hash]
    #   Where keys are `:builtin`, `:profile`, and `:custom`,
    #   and where values are arrays of hashes, where each hash contains:
    #     - `:path` (String) - Absolute path to SKM file.
    #     - `:display_name` (String) - Material display name.
    #     - `:thumbnail_uri` (String) - SKM thumbnail file URI.
    #     - `:type` (String) - Material type. e.g. "ceramic"
    def self.files
      @@files
    end

    # Absolute path to built-in SKM library directory.
    # Materials shipped with SketchUp are stored here.
    #
    # @raise [RuntimeError]
    #
    # @return [String]
    def self.builtin_library_path
      sketchup_year_version = "20#{Sketchup.version.to_i}"

      if Sketchup.platform == :platform_osx
        File.join(
          '/', 'Applications', 'SketchUp ' + sketchup_year_version,
          'SketchUp.app', 'Contents', 'Resources', 'Content', 'Materials'
        )

      elsif Sketchup.platform == :platform_win
        File.join(
          ENV['PROGRAMDATA'], 'SketchUp', 'SketchUp ' + sketchup_year_version,
          'SketchUp', 'Materials'
        )
        
      else
        raise 'Unknown operating system.'
      end
    end

    # Absolute path to user profile SKM library directory, configurable in SketchUp.
    # Not to be confused with custom SKM library pointed by user in Material Browser.
    #
    # @raise [RuntimeError]
    #
    # @return [String]
    def self.profile_library_path
      sketchup_year_version = "20#{Sketchup.version.to_i}"

      if Sketchup.platform == :platform_osx
        File.join(
          ENV['HOME'], 'Library', 'Application Support',
          'SketchUp ' + sketchup_year_version, 'SketchUp', 'Materials'
        )

      elsif Sketchup.platform == :platform_win
        File.join(
          ENV['APPDATA'], 'SketchUp', 'SketchUp ' + sketchup_year_version,
          'SketchUp', 'Materials'
        )

      else
        raise 'Unknown operating system.'
      end
    end

    # Absolute path to a given SKM library.
    #
    # @param [Symbol] library `:builtin`, `:profile`, or `:custom`
    # @raise [ArgumentError]
    #
    # @raise [RuntimeError]
    #   If library is `:custom` and its path is not defined.
    #
    # @return [String]
    def self.library_path(library)
      raise ArgumentError, 'library must be a Symbol.' \
        unless [:builtin, :profile, :custom].include?(library)

      if :custom == library && Settings.current.custom_skm_path.empty?
        raise 'Material Browser: No custom SKM path set.'
      end

      case library
      when :builtin
        builtin_library_path
      when :profile
        profile_library_path
      when :custom
        Settings.current.custom_skm_path
      end
    end

    # Absolute path to SKM thumbnails directory of a given library.
    #
    # @param [Symbol] library `:builtin`, `:profile`, or `:custom`
    # @raise [ArgumentError]
    #
    # @return [String]
    def self.thumbnails_path(library)
      raise ArgumentError, 'library must be a Symbol.' \
        unless [:builtin, :profile, :custom].include?(library)

      sketchup_year_version = "20#{Sketchup.version.to_i}"

      case library
      when :builtin
        # Remark: We use here a different thumbnails directory for each SketchUp version
        # to avoid losing, at cleanup time, thumbnails of other installed SketchUp versions.
        # It would be a waste of time for Material Browser plugin to extract them again...
        File.join(
          Sketchup.temp_dir,
          "SketchUp #{sketchup_year_version} MBR Plugin SKM Thumbs"
        )
      when :profile
        # Same here.
        File.join(
          Sketchup.temp_dir,
          "SketchUp #{sketchup_year_version} MBR Plugin P-SKM Thumbs"
        )
      when :custom
        File.join(Sketchup.temp_dir, "SketchUp MBR Plugin C-SKM Thumbs")
      end
    end

    # Extracts thumbnails from SKM files stored in a given library and loads their metadata.
    # If `then_cleanup` parameter is `true`, it removes also outdated/unused thumbnails.
    # After that, those metadata are accessible through `SKM.files`.
    #
    # @param [Symbol] library `:builtin`, `:profile`, or `:custom`
    # @param [Boolean] then_cleanup
    # @raise [ArgumentError]
    #
    # @return [Boolean]
    #   `true` if it was possible to extract thumbnails, `false` otherwise.
    def self.extract_thumbnails(library, then_cleanup: false)
      raise ArgumentError, 'library must be a Symbol.' \
        unless [:builtin, :profile, :custom].include?(library)

      raise ArgumentError, 'then_cleanup must be a Boolean.' \
        unless [true, false].include?(then_cleanup)

      lib_path = library_path(library)

      unless Dir.exist?(lib_path)
        warn "Material Browser: SKM library directory does not exist: #{lib_path}"
        return false
      end

      skm_files_glob_pattern = File.join(lib_path, '**', '*.skm')
      skm_files_glob_pattern.gsub!('\\', '/') if Sketchup.platform == :platform_win

      used_thumbnails = []

      thumbs_path = thumbnails_path(library)
      FileUtils.mkdir_p(thumbs_path) unless Dir.exist?(thumbs_path)

      @@files[library].clear

      Dir.glob(skm_files_glob_pattern).each do |skm_file_path|
        thumbnail_basename = Zlib.crc32(skm_file_path).to_s
        thumbnail_basename += '@' + File.mtime(skm_file_path).to_i.to_s + '.png'

        used_thumbnails.push(thumbnail_basename) if then_cleanup

        thumbnail_path = File.join(thumbs_path, thumbnail_basename)
        thumbnail_available = File.exist?(thumbnail_path)

        # To index SKM files faster:
        # We don't re-extract thumbnails of SKM files having same path and modification time.
        # This isn't perfect... There are cases where a thumbnail shouldn't be re-extracted:
        # - A SKM file with no intrinsic change have been moved/renamed.
        # - A SKM file contents has been modified in a way that didn't affect its thumbnail.
        # But I think it's less bad than displaying outdated thumbnails, more user-friendly.
        # In an ideal world, SKM files are deep-compared...
        unless thumbnail_available
          thumbnail_available = Unzip.file(skm_file_path, 'doc_thumbnail.png', thumbnail_path)
          # SKM files are ZIP files.

          unless thumbnail_available
            warn "Material Browser: Failed to extract thumbnail from: #{skm_file_path}"
          end
        end

        if thumbnail_available
          skm_display_name = File.basename(skm_file_path).sub('.skm', '').gsub('_', ' ')

          @@files[library].push({
            path: skm_file_path,
            display_name: skm_display_name,
            thumbnail_uri: Path.to_uri(thumbnail_path),
            type: MaterialsTypes.get.from_words(Words.clean(skm_display_name))
          })
        end
      end

      if then_cleanup
        thumbs_glob_pattern = File.join(thumbs_path, '**', '*.png')
        thumbs_glob_pattern.gsub!('\\', '/') if Sketchup.platform == :platform_win

        Dir.glob(thumbs_glob_pattern).each do |thumbnail_path|
          unless used_thumbnails.include?(File.basename(thumbnail_path))
            FileUtils.remove_file(thumbnail_path) # Since it's outdated or no longer used.
          end
        end
      end

      true
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
