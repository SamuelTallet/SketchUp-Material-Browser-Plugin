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

    # Sets "zoom value" setting.
    #
    # @param [Integer] zoom_value
    def set_zoom_value(zoom_value)
      @settings['zoom_value'] = zoom_value
    end

    # Gets "zoom value" setting.
    #
    # @return [Integer]
    def get_zoom_value
      @settings['zoom_value']
    end

    # Sets "source filter value" setting.
    #
    # @param [Integer] source_filter_value
    def set_source_filter_value(source_filter_value)
      @settings['source_filter_value'] = source_filter_value
    end

    # Gets "source filter value" setting.
    #
    # @return [Integer]
    def get_source_filter_value
      @settings['source_filter_value']
    end

    # Sets "custom SKM path" setting.
    #
    # @param [String] path
    def set_custom_skm_path(custom_skm_path)

      @settings['custom_skm_path'] = custom_skm_path

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

    # Sets "display value" setting.
    #
    # @param [String] display_value
    def set_display_value(display_value)
      @settings['display_value'] = display_value
    end

    # Gets "display value" setting.
    #
    # @return [String]
    def get_display_value
      @settings['display_value']
    end

    # Writes settings to disk.
    def write
      File.write(JSON_FILE, JSON.pretty_generate(@settings))
    end

  end

end
