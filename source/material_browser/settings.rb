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
require 'json'
require 'sketchup'

# Material Browser plugin namespace.
module MaterialBrowser

  # User-defined settings.
  class Settings

    # Absolute path to JSON file storing settings.
    JSON_FILE = File.join(__dir__, 'settings.json')

    # Default zoom value.
    DEFAULT_ZOOM_VALUE = 160

    # Maximum zoom value.
    MAX_ZOOM_VALUE = 256

    # Singleton instance.
    @instance = nil

    # Current settings (singleton instance).
    def self.current
      @instance ||= new
    end

    # Makes a `Settings` object.
    private def initialize
      @settings = {
        'zoom_value' => DEFAULT_ZOOM_VALUE,
        'display_name' => false,
        'custom_skm_path' => '',
        'type_filter_value' => 'all'
      }
    end

    # Reads settings from disk, if such file exists.
    def read
      return unless File.exist?(JSON_FILE)

      begin
        @settings = JSON.parse(File.read(JSON_FILE))
      rescue => error
        warn "Material Browser: Can't read settings: #{error.message}"
      end
    end

    # Sets "zoom value" setting.
    #
    # @param [Integer] zoom_value
    # @raise [ArgumentError]
    def zoom_value=(zoom_value)

      raise ArgumentError, 'Zoom value must be a strictly positive Integer.'\
        unless zoom_value.is_a?(Integer) and zoom_value > 0

      raise ArgumentError, "Zoom value must not exceed #{MAX_ZOOM_VALUE}."\
        unless zoom_value <= MAX_ZOOM_VALUE

      @settings['zoom_value'] = zoom_value
    end

    # Gets "zoom value" setting.
    #
    # @return [Integer]
    def zoom_value
      @settings['zoom_value']
    end

    # Sets "display name" setting.
    #
    # @param [Boolean] display_name
    # @raise [ArgumentError]
    def display_name=(display_name)

      raise ArgumentError, 'Display name must be a Boolean.'\
        unless [true, false].include?(display_name)

      @settings['display_name'] = display_name
    end

    # Gets "display name" setting.
    #
    # @return [Boolean]
    def display_name?
      @settings['display_name']
    end

    # Sets "custom SKM path" setting.
    #
    # @param [String] custom_skm_path
    # @raise [ArgumentError]
    def custom_skm_path=(custom_skm_path)

      raise ArgumentError, 'Custom SKM path must be a String.'\
        unless custom_skm_path.is_a?(String)

      @settings['custom_skm_path'] = custom_skm_path
    end

    # Gets "custom SKM path" setting.
    #
    # @return [String]
    def custom_skm_path
      @settings['custom_skm_path']
    end

    # Sets "type filter value" setting.
    #
    # @param [String] type_filter_value
    # @raise [ArgumentError]
    def type_filter_value=(type_filter_value)

      raise ArgumentError, 'Type filter value must be a String.'\
        unless type_filter_value.is_a?(String)

      @settings['type_filter_value'] = type_filter_value
    end

    # Gets "type filter value" setting.
    #
    # @return [String]
    def type_filter_value
      @settings['type_filter_value']
    end

    # Writes settings to disk.
    def write
      begin
        File.write(JSON_FILE, JSON.pretty_generate(@settings))
      rescue => error
        warn "Material Browser: Can't write settings: #{error.message}"
      end
    end

  end

end
