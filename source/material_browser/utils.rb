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

require 'sketchup'
require 'erb'
require 'open-uri'
require 'fileutils'
require 'zip'

# Material Browser plugin namespace.
module MaterialBrowser

  # @todo Split into multiple files.
  module Utils

    # Converts a path to a file URI.
    #
    # @param [String] path
    # @raise [ArgumentError]
    #
    # @return [String] URI.
    def self.path2uri(path)

      raise ArgumentError, 'Path must be a String.' unless path.is_a?(String)

      # Fix path only on Windows.
      path.gsub!('\\', '/') if Sketchup.platform == :platform_win

      uri = ERB::Util.url_encode(path)

      # Fix URI only on Windows.
      uri.gsub!('%3A', ':') if Sketchup.platform == :platform_win

      uri.gsub!('%2F', '/')

      'file:///' + uri

    end

    # Mimics PHP `ucwords` function.
    # See: https://github.com/maintainable/php-ruby-reference/blob/master/strings/ucwords.markdown
    #
    # @param [String] words
    # @raise [ArgumentError]
    #
    # @return [String] Words.
    def self.ucwords(words)

      raise ArgumentError, "This isn't a String." unless words.is_a?(String)

      words.split(' ').select { |word| word.capitalize! || word }.join(' ')

    end

    # Cleans a word list.
    #
    # @param [String] words Space-separated words.
    # @raise [ArgumentError]
    #
    # @return [String] Words.
    def self.clean_words(words)

      raise ArgumentError, "This isn't a String." unless words.is_a?(String)
      
      words.gsub(/[^\p{L}\- ]/, '')

    end

    # Downloads a file from an URL.
    #
    # @param [String] url
    # @param [String] user_agent
    # @param [String] output_path
    # @raise [ArgumentError]
    #
    # @return [Boolean] true if download succeeded, false if download failed.
    def self.download(url, user_agent, output_path)

      raise ArgumentError, 'URL must be a String.'\
        unless url.is_a?(String)
      raise ArgumentError, 'User Agent must be a String.'\
        unless user_agent.is_a?(String)
      raise ArgumentError, 'Output path must be a String.'\
        unless output_path.is_a?(String)

      begin

        File.open(output_path, 'wb') do |output_file|

          output_file.write(
            URI.open(url, 'User-Agent' => user_agent).read
          )
          output_file.close
          
        end

      rescue => error

        puts 'Error: ' + error.message

        return false
        
      end

      true

    end

    # Extracts a file from a ZIP archive file.
    #
    # @param [String] zip_file_path
    # @param [String] file_to_extract
    # @param [String] output_path
    # @raise [ArgumentError]
    #
    # @return [Boolean] true if extract succeeded, false if extract failed.
    def self.unzip(zip_file_path, file_to_extract, output_path)

      raise ArgumentError, 'URL must be a String.'\
        unless zip_file_path.is_a?(String)
      raise ArgumentError, 'File to extract must be a String.'\
        unless file_to_extract.is_a?(String)
      raise ArgumentError, 'Output path must be a String.'\
        unless output_path.is_a?(String)

      begin
        # @todo Drop RubyZip because it's slow when there are many archives
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
        puts 'Error: ' + error.message
        return false
      end

      true
    end

  end

end
