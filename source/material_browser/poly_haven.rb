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

require 'json'
require 'sketchup'

# Material Browser plugin namespace.
module MaterialBrowser

  # Manages Poly Haven textures.
  # @todo Complete this module.
  module PolyHaven

    # Base URL of Poly Haven API.
    # See: https://redocly.github.io/redoc/?url=https://api.polyhaven.com/api-docs/swagger.json
    API_URL = 'https://api.polyhaven.com'

    # Absolute path to "Poly Haven" directory.
    DIR = File.join(__dir__, 'Poly Haven')

    # Absolute path to a minimal Poly Haven textures index file.
    # This index is distributed with Material Browser.
    MINI_INDEX_FILE = File.join(DIR, 'textures.json')

    # Absolute path to Poly Haven textures thumbnails directory.
    # These thumbnails are distributed with Material Browser.
    THUMBNAILS_DIR = File.join(DIR, 'Thumbnails')

    # Fetches textures index and thumbnails from Poly Haven API.
    def self.fetch_textures
      # Where each key is texture slug and each value is its size in meters.
      # @type [Hash<String, Float>]
      minimal_index = {}

      request = Sketchup::Http::Request.new(API_URL + '/assets?type=textures')
      request.headers = { 'User-Agent' => USER_AGENT }

      request.start do |_request, response|
        unless response.status_code == 200 # OK
          raise "Material Browser: Poly Haven API Error: #{response.body}"
        end
        # @type [Hash<String, Hash>]
        textures = JSON.parse(response.body)

        textures.each do |slug, metadata|
          # @type [Integer, Float]
          # Example: 2049.999713897705
          millimeters = metadata['dimensions'][0] # We assume a square.
          meters = millimeters.round / 1000.0

          minimal_index[slug] = meters
          # @todo Download texture thumbnail.
        end

        # Overwrites minimal index file.
        File.write(MINI_INDEX_FILE, JSON.pretty_generate(minimal_index))
      end
    end

    # Poly Haven textures metadata.
    @@textures = []

    def self.textures
      @@textures
    end

  end

end
