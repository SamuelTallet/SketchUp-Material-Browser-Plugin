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

# Material Browser plugin namespace.
module MaterialBrowser

  # Stores materials thumbnails and textures.
  module Cache

    # Gets absolute path to materials thumbnails directory.
    #
    # @return [String]
    def self.materials_thumbnails_path
      File.join(Sketchup.temp_dir, 'SketchUp MBR Plugin Thumbnails')
    end

    # Removes materials thumbnails directory.
    def self.remove_materials_thumbnails_dir
      FileUtils.remove_dir(materials_thumbnails_path) if Dir.exist?(materials_thumbnails_path)
    end

    # Creates materials thumbnails directory.
    def self.create_materials_thumbnails_dir
      FileUtils.mkdir_p(materials_thumbnails_path) unless Dir.exist?(materials_thumbnails_path)
    end

    # Gets absolute path to materials textures directory.
    #
    # @return [String]
    def self.materials_textures_path
      File.join(Sketchup.temp_dir, 'SketchUp MBR Plugin Textures')
    end

    # Removes materials textures directory.
    def self.remove_materials_textures_dir
      FileUtils.remove_dir(materials_textures_path) if Dir.exist?(materials_textures_path)
    end

    # Creates materials textures directory.
    def self.create_materials_textures_dir
      FileUtils.mkdir_p(materials_textures_path) unless Dir.exist?(materials_textures_path)
    end

    # Deletes materials textures older than a month.
    def self.delete_old_materials_textures

      materials_textures_ctime_glob_pattern = File.join(materials_textures_path, '*.ctime')

      # Fix materials textures... glob pattern only on Windows.
      materials_textures_ctime_glob_pattern.gsub!('\\', '/')\
        if Sketchup.platform == :platform_win

      Dir.glob(materials_textures_ctime_glob_pattern).each do |material_texture_ctime_file|

        material_texture_ctime = File.read(material_texture_ctime_file).to_i
        one_month_ago = Time.now.to_i - 2592000

        if material_texture_ctime < one_month_ago

          File.delete(material_texture_ctime_file)
          File.delete(material_texture_ctime_file.sub('.ctime', ''))

        end

      end

    end

  end

end
