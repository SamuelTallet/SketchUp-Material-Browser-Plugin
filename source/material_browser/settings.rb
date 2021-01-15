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

require 'fileutils'
require 'json'
require 'sketchup'

# Material Browser plugin namespace.
module MaterialBrowser

  # User-defined settings.
  class Settings

    # Absolute path to "./settings.json".
    JSON_FILE = File.join(__dir__, 'settings.json')

    # Makes a Settings object.
    def initialize
      @settings = {}
    end

    # Reads settings from disk.
    def read

      begin

        @settings = JSON.parse(File.read(JSON_FILE))

      rescue => error

        puts 'Error: ' + error.message

        # If something went wrong: read "./settings.json.backup".
        @settings = JSON.parse(File.read(JSON_FILE + '.backup'))

      end

    end

    # Sets "material thumbnails zoom" setting.
    #
    # @param [Integer] value
    def set_material_thumbnails_zoom(value)
      @settings['material_thumbnails_zoom'] = value
    end

    # Gets "material thumbnails zoom" setting.
    #
    # @return [Integer]
    def get_material_thumbnails_zoom
      @settings['material_thumbnails_zoom']
    end

    # Sets "material thumbnails display" setting.
    #
    # @param [String] value
    def set_material_thumbnails_display(value)
      @settings['material_thumbnails_display'] = value
    end

    # Gets "material thumbnails display" setting.
    #
    # @return [String]
    def get_material_thumbnails_display
      @settings['material_thumbnails_display']
    end

    # Sets "custom SKM path" setting.
    #
    # @param [String] path
    def set_custom_skm_path(value)

      @settings['custom_skm_path'] = value

      UI.messagebox(
        TRANSLATE['You must restart SketchUp to see changes in Material Browser UI.']
      )

    end

    # Gets "custom SKM path" setting.
    #
    # @return [String]
    def get_custom_skm_path
      @settings['custom_skm_path']
    end

    # Writes settings to disk.
    def write
      File.write(JSON_FILE, JSON.pretty_generate(@settings))
    end

  end

end
