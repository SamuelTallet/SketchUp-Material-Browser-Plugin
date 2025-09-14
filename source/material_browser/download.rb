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
require 'openssl'
require 'fileutils'

# Material Browser plugin namespace.
module MaterialBrowser

  # Download helper.
  module Download

    # Tries to download a file from an URL, synchronously.
    #
    # @param [String] url
    # @param [String] output_path
    # @raise [ArgumentError]
    #
    # @raise [RuntimeError] if download failed.
    def self.file(url, output_path)
      raise ArgumentError, 'URL must be a String.'\
        unless url.is_a?(String)
      raise ArgumentError, 'Output path must be a String.'\
        unless output_path.is_a?(String)

      begin
        File.open(output_path, 'wb') do |output_file|
          stream = if RUBY_VERSION.to_f >= 2.5
            URI.open(url, 'User-Agent' => USER_AGENT)
          else
            open(
              url,
              'User-Agent' => USER_AGENT,
              :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE
            )
          end
          output_file.write(stream.read)
          # Remarks:
          # - > open-uri's Kernel.open will be deprecated in future.
          # - URI.open() is callable since Ruby 2.5, else we fallback to open()
          # - User-Agent is required by some APIs, including Poly Haven one.
          # - Seems SketchUp 2017 (Ruby 2.2.4) has trouble with modern SSL.
          # - Output file is overwritten if it already exists.
        end
      rescue => error
        FileUtils.remove_file(output_path) if File.exist?(output_path) # Cleanup
        raise "Download failed with #{error.message} for #{url}"
      end
    end

  end

end
