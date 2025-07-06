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
require 'material_browser/download'
require 'material_browser/words'
require 'material_browser/fs'
require 'material_browser/materials_types'
require 'material_browser/textures_cache'

# Material Browser plugin namespace.
module MaterialBrowser

  # Manages Poly Haven textures.
  module PolyHaven

    # Base URL of Poly Haven API.
    # See: https://redocly.github.io/redoc/?url=https://api.polyhaven.com/api-docs/swagger.json
    API_URL = 'https://api.polyhaven.com'

    # Base URL of Poly Haven site.
    SITE_URL = 'https://polyhaven.com'

    # Absolute path to "Poly Haven" directory.
    DIR = File.join(__dir__, 'Poly Haven')

    # Absolute path to Poly Haven textures index file.
    TEX_INDEX_FILE = File.join(DIR, 'textures.json')

    # Absolute path to Poly Haven assets thumbnails directory.
    THUMBS_DIR = File.join(DIR, 'Thumbnails')

    # Index file and thumbnails are included in plugin's RBZ package because:
    # - Poly Haven API is a free service so I don't want to abuse it.
    # - This pre-download accelerates Material Browser's UI first opening.

    # Fetches textures index and thumbnails from Poly Haven API.
    # Warning: This is a blocking operation for internal use only.
    def self.fetch_textures
      # Where each key is texture slug and each value is its size in meters.
      # @type [Hash<String, Float>]
      local_index = {}

      request = Sketchup::Http::Request.new(API_URL + '/assets?type=textures')
      # Poly Haven API requires "a unique User-Agent header".
      # See: https://polyhaven.com/our-api
      request.headers = { 'User-Agent' => USER_AGENT }

      request.start do |_request, response|
        unless response.status_code == 200 # OK
          raise "Material Browser: Can't fetch Poly Haven textures index: #{response.body}"
        end

        # @type [Hash<String, Hash>]
        textures = JSON.parse(response.body)

        textures.each do |slug, metadata|
          # @type [Integer, Float]
          # Example: 2049.999713897705
          millimeters = metadata['dimensions'][0] # We assume a square texture.
          meters = millimeters.round / 1000.0

          # Adds texture to local index.
          local_index[slug] = meters

          # @type [String]
          # Example: https://cdn.polyhaven.com/asset_img/thumbs/mud_forest.png?width=256&height=256
          thumb_url = metadata['thumbnail_url']

          # Currently, Poly Haven's CDN forces WebP format for thumbnails.
          # @todo Detect used image format and don't always expect WebP?
          thumb_file = File.join(THUMBS_DIR, "#{slug}.webp")

          # @todo Find a more robust way to ensure existing thumbnail is valid.
          next if File.exist?(thumb_file) && File.size(thumb_file) > 0

          unless Download.file(thumb_url, thumb_file)
            raise "Material Browser: Poly Haven texture thumbnail download failed for #{slug}."
          end
          sleep(0.3) # Avoids overloading API with too many requests.
        end

        # Overwrites index file.
        File.write(TEX_INDEX_FILE, JSON.pretty_generate(local_index))

        UI.messagebox "We now have #{local_index.size} Poly Haven textures."
      end
    end

    # Poly Haven textures metadata.
    @@textures = []

    # Metadata of Poly Haven textures.
    #
    # @return [Array<Hash>]
    #   Where each hash contains:
    #   - `:slug` (String) - Texture ID. e.g. "brick_pavement_02".
    #   - `:name` (String) - Texture name, derived from its slug.
    #   - `:meters` (Float) - Texture size, in meters.
    #   - `:thumbnail_uri` (String) - Texture thumbnail file URI.
    #   - `:type` (String) - Material type. e.g. "brick"
    def self.textures
      @@textures
    end

    # Starting from local index file, extrapolates metadata of Poly Haven textures.
    # After that, those metadata are accessible through `PolyHaven.textures`.
    def self.load_textures
      @@textures.clear

      # @type [Hash<String, Float>]
      local_index = JSON.parse(File.read(TEX_INDEX_FILE))

      local_index.each do |texture_slug, texture_size_in_meters|
        # Example: "brick_pavement_02" --> "Brick Pavement 02"
        texture_name = Words.upper(texture_slug.gsub('_', ' '))

        @@textures << {
          slug: texture_slug,
          name: texture_name,
          meters: texture_size_in_meters,
          thumbnail_uri: FS.path2uri(File.join(THUMBS_DIR, "#{texture_slug}.webp")),
          type: MaterialsTypes.get.from_words(texture_name)
        }
      end

      nil
    end

    # Metadata of a given Poly Haven texture.
    # @param [String] texture_slug
    #
    # @return [Hash]
    def self.texture_metadata(texture_slug)
      metadata = @@textures.find { |texture| texture[:slug] == texture_slug }

      raise "Material Browser: No Poly Haven texture metadata found for #{texture_slug}." \
        unless metadata.is_a?(Hash)

      metadata
    end

    # Fetches texture files from Poly Haven API.
    # @param [String] texture_slug
    #
    # @yieldparam [Hash] files
    def self.texture_files(texture_slug)
      request = Sketchup::Http::Request.new(API_URL + '/files/' + texture_slug)
      request.headers = { 'User-Agent' => USER_AGENT } # Required

      request.start do |_request, response|
        unless response.status_code == 200 # OK
          raise "Material Browser: Can't fetch Poly Haven texture files: #{response.body}"
        end

        yield JSON.parse(response.body)
      end
    end

    # Selects a Poly Haven texture.
    # @param [String] texture_slug
    def self.select_texture(texture_slug)
      raise ArgumentError, "Texture Slug must be a String." unless texture_slug.is_a?(String)

      TexturesCache.create_dir
      metadata = texture_metadata(texture_slug)

      texture_files(texture_slug) { |files|
        diffuse_file = File.join(TexturesCache.path, "ph_#{texture_slug}_diffuse.jpg")

        unless File.exist?(diffuse_file)
          unless files.dig('Diffuse', '4k', 'jpg', 'url')
            raise "Material Browser: Poly Haven #{texture_slug} diffuse texture is missing."
          end
          unless Download.file(files['Diffuse']['4k']['jpg']['url'], diffuse_file)
            FileUtils.remove_file(diffuse_file) if File.exist?(diffuse_file) # Clean up
            raise "Material Browser: Can't get Poly Haven #{texture_slug} diffuse texture."
          end
        end

        material = Sketchup.active_model.materials.add("#{metadata[:name]} - Poly Haven")
        material.texture = diffuse_file

        # @todo Set available PBR textures: normal, roughness, metallic, etc.

        material.texture.size = metadata[:meters].m # => Inches
        Sketchup.active_model.materials.current = material

        Sketchup.send_action('selectPaintTool:')
      }
    end

  end

end
