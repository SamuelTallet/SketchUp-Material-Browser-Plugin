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

require 'open-uri'
require 'fileutils'

# Material Browser plugin namespace.
module MaterialBrowser

  # Download helper.
  module Download

    # Downloads a file from an URL, synchronously.
    #
    # @param [String] url
    # @param [String] output_path
    # @raise [ArgumentError]
    #
    # @return [Boolean] true if download succeeded, false if download failed.
    def self.file(url, output_path)
      raise ArgumentError, 'URL must be a String.'\
        unless url.is_a?(String)
      raise ArgumentError, 'Output path must be a String.'\
        unless output_path.is_a?(String)

      begin
        File.open(output_path, 'wb') do |output_file|
          output_file.write(
            URI.open(url, 'User-Agent' => USER_AGENT).read
          )
          # Remarks:
          # - User-Agent is required by some APIs, including Poly Haven one.
          # - Seems HTTP redirects are not followed?
          # - Output file is overwritten if it already exists.
        end
      rescue => error
        warn "Material Browser: Download failed with #{error.message} for #{url}"
        return false
      end

      true
    end

  end

end
