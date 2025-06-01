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
require 'fileutils'

# Material Browser plugin namespace.
module MaterialBrowser

  # Manages materials types.
  class MaterialsTypes

    # Absolute path to "Materials Types" directory.
    DIR = File.join(__dir__, 'Materials Types')

    @instance = nil

    # Gets singleton instance of `MaterialsTypes`.
    def self.get
      @instance ||= new
    end

    # Makes a `MaterialsTypes` object.
    private def initialize

      @dictionary = {}
      load_dictionary

    end

    # Loads materials types dictionary.
    # NB: If a locale dictionary exists: it's merged with default english one.
    private def load_dictionary

      @dictionary = JSON.parse(File.read(File.join(DIR, 'en.dictionary.json')))

      return if Sketchup.get_locale == 'en-US' or Sketchup.get_locale == 'en-GB'

      locale_dictionary_path = File.join(DIR, Sketchup.get_locale + '.dictionary.json')

      if File.exist?(locale_dictionary_path)
        @dictionary = @dictionary.merge(JSON.parse(File.read(locale_dictionary_path)))
      end

    end

    # Tries to get a material type from a word.
    #
    # @param [String] word
    # @raise [ArgumentError]
    #
    # @return [String] material type or 'unknown' if word isn't in dictionary.
    private def from_word(word)

      raise ArgumentError, 'Word must be a String.' unless word.is_a?(String)

      normalized_word = word.downcase

      if @dictionary.key?(normalized_word)
        @dictionary[normalized_word]
      else
        'unknown'
      end

    end

    # Tries to get a material type from a word list.
    #
    # @param [String] words Space-separated words.
    # @raise [ArgumentError]
    #
    # @return [String] material type or 'unknown' if words aren't in dictionary.
    def from_words(words)

      raise ArgumentError, 'Words must be a String.' unless words.is_a?(String)

      material_type = 'unknown'
      words_array = words.split(' ')

      words_array.each do |word|

        material_type = from_word(word)
        break if material_type != 'unknown'

      end

      material_type
      
    end

  end

end
