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
require 'erb'
require 'material_browser/path'

# Material Browser plugin namespace.
module MaterialBrowser

  # Helps construct HTML dialogs.
  module HTMLDialogs

    # Absolute path to "HTML Dialogs" directory.
    DIR = File.join(__dir__, 'HTML Dialogs')

    # Absolute path to "HTML Dialogs/images" directory.
    IMAGES_DIR = File.join(DIR, 'images')

    # Merges RHTML, JS and CSS.
    #
    # @param [Hash] args Arguments.
    # @raise [ArgumentError]
    #
    # @return [String] HTML document that incorporates scripts and styles.
    def self.merge(args)
      raise ArgumentError, 'Document must be a String.' \
        unless args[:document].is_a?(String)

      scripts = asset_contents_by_uri(args[:scripts], 'script')
      styles = asset_contents_by_uri(args[:styles], 'style')
      # Note: From now, these variables are available in RHTML document.

      ERB.new(File.read(File.join(DIR, args[:document]))).result(binding)
    end

    # Converts an image's filename to a file URI.
    # This filename is relative to `IMAGES_DIR`.
    #
    # @param [String] filename Image's filename.
    # @raise [ArgumentError]
    #
    # @return [String] An absolute image file URI.
    def self.img_uri(filename)
      raise ArgumentError, 'Filename must be a String.' \
        unless filename.is_a?(String)

      file_path = File.join(IMAGES_DIR, filename)
      raise "#{filename} was not found in #{IMAGES_DIR}" \
        unless File.exist?(file_path)

      Path.to_uri(file_path)
    end

    # Loads assets contents given their relative URI.
    # See: `DIR` to know which path they're relative to.
    #
    # @private
    #
    # @param [Array] assets_uris Relative URIs of assets to load...
    # @raise [ArgumentError]
    #
    # @param [String] final_html_tag Final HTML tag (e.g. 'script').
    # @raise [ArgumentError]
    #
    # @return [Hash] The assets contents indexed by URI.
    def self.asset_contents_by_uri(assets_uris, final_html_tag)

      raise ArgumentError, 'Assets URIs must be an Array.'\
       unless assets_uris.is_a?(Array)

      raise ArgumentError unless final_html_tag.is_a?(String)

      asset_contents = {}

      assets_uris.each do |asset_uri|

        # Asset contents is enclosed in final HTML tag passed as parameter.
        asset_contents[asset_uri] = "<#{final_html_tag}>"
        asset_contents[asset_uri] += File.read(File.join(DIR, asset_uri))
        asset_contents[asset_uri] += "</#{final_html_tag}>"

      end

      asset_contents
    end

    private_class_method :asset_contents_by_uri

  end

end
