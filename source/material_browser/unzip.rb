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

# Requires Rubyzip gem if not already loaded.
unless defined?(Zip)
  $LOAD_PATH.push(File.join(__dir__, 'Rubyzip'))
  require 'zip'
end

# Material Browser plugin namespace.
module MaterialBrowser

  # Unzip helper.
  module Unzip

    # Extracts a file from a ZIP archive file.
    #
    # @param [String] zip_file_path
    # @param [String] file_to_extract
    # @param [String] output_path
    # @raise [ArgumentError]
    #
    # @return [Boolean] true if extract succeeded, false if extract failed.
    def self.file(zip_file_path, file_to_extract, output_path)

      raise ArgumentError, 'URL must be a String.'\
        unless zip_file_path.is_a?(String)
      raise ArgumentError, 'File to extract must be a String.'\
        unless file_to_extract.is_a?(String)
      raise ArgumentError, 'Output path must be a String.'\
        unless output_path.is_a?(String)

      begin
        # @todo Drop Rubyzip because it's slow when there are many archives
        # to extract. Instead load an "unzip.dll" with Fiddle?
        Zip::File.open(zip_file_path) do |zip_file|
          zip_file.each do |zip_file_entry|

            if zip_file_entry.name == file_to_extract
              # Note this method doesn't overwrite files.
              zip_file_entry.extract(output_path)
              break
            end

          end
        end
      rescue => error
        warn "Material Browser: Unzip failed: #{error.message}"
        return false
      end

      true
    end

  end

end
