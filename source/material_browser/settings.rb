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
        'always_display_name' => false,
        'display_custom_skm' => false,
        'display_profile_skm' => false,
        'display_builtin_skm' => false,
        'display_poly_haven' => true,
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

    # Sets "Zoom value" setting.
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

    # Gets "Zoom value" setting.
    #
    # @return [Integer]
    def zoom_value
      @settings['zoom_value']
    end

    # Sets "Always display name" setting.
    #
    # @param [Boolean] always_display_name
    # @raise [ArgumentError]
    def always_display_name=(always_display_name)

      raise ArgumentError, 'Always display name must be a Boolean.'\
        unless [true, false].include?(always_display_name)

      @settings['always_display_name'] = always_display_name
    end

    # Gets "Always display name" setting.
    #
    # @return [Boolean]
    def always_display_name?
      @settings['always_display_name']
    end

    # Sets "Display custom SKM" setting.
    #
    # @param [Boolean] display_custom_skm
    # @raise [ArgumentError]
    def display_custom_skm=(display_custom_skm)

      raise ArgumentError, 'Display custom SKM must be a Boolean.'\
        unless [true, false].include?(display_custom_skm)

      @settings['display_custom_skm'] = display_custom_skm
    end

    # Gets "Display custom SKM" setting.
    #
    # @return [Boolean]
    def display_custom_skm?
      @settings['display_custom_skm']
    end

    # Sets "Display profile SKM" setting.
    #
    # @param [Boolean] display_profile_skm
    # @raise [ArgumentError]
    def display_profile_skm=(display_profile_skm)

      raise ArgumentError, 'Display profile SKM must be a Boolean.'\
        unless [true, false].include?(display_profile_skm)

      @settings['display_profile_skm'] = display_profile_skm
    end

    # Gets "Display profile SKM" setting.
    #
    # @return [Boolean]
    def display_profile_skm?
      @settings['display_profile_skm']
    end

    # Sets "Display built-in SKM" setting.
    #
    # @param [Boolean] display_builtin_skm
    # @raise [ArgumentError]
    def display_builtin_skm=(display_builtin_skm)

      raise ArgumentError, 'Display built-in SKM must be a Boolean.'\
        unless [true, false].include?(display_builtin_skm)

      @settings['display_builtin_skm'] = display_builtin_skm
    end

    # Gets "Display built-in SKM" setting.
    #
    # @return [Boolean]
    def display_builtin_skm?
      @settings['display_builtin_skm']
    end

    # Sets "Display Poly Haven" setting.
    #
    # @param [Boolean] display_poly_haven
    # @raise [ArgumentError]
    def display_poly_haven=(display_poly_haven)

      raise ArgumentError, 'Display Poly Haven must be a Boolean.'\
        unless [true, false].include?(display_poly_haven)

      @settings['display_poly_haven'] = display_poly_haven
    end

    # Gets "Display Poly Haven" setting.
    #
    # @return [Boolean]
    def display_poly_haven?
      @settings['display_poly_haven']
    end

    # Sets "Custom SKM path" setting.
    #
    # @param [String] custom_skm_path
    # @raise [ArgumentError]
    def custom_skm_path=(custom_skm_path)

      raise ArgumentError, 'Custom SKM path must be a String.'\
        unless custom_skm_path.is_a?(String)

      @settings['custom_skm_path'] = custom_skm_path
    end

    # Gets "Custom SKM path" setting.
    #
    # @return [String]
    def custom_skm_path
      @settings['custom_skm_path']
    end

    # Sets "Type filter value" setting.
    #
    # @param [String] type_filter_value
    # @raise [ArgumentError]
    def type_filter_value=(type_filter_value)

      raise ArgumentError, 'Type filter value must be a String.'\
        unless type_filter_value.is_a?(String)

      @settings['type_filter_value'] = type_filter_value
    end

    # Gets "Type filter value" setting.
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
