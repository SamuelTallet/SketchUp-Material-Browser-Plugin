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

# Material Browser plugin namespace.
module MaterialBrowser

  # Words functions.
  module Words

    # Mimics PHP `ucwords` function.
    # See: https://github.com/maintainable/php-ruby-reference/blob/main/strings/ucwords.markdown
    #
    # @param [String] words
    # @raise [ArgumentError]
    #
    # @return [String] Words.
    def self.upper(words)
      raise ArgumentError, "This isn't a String." unless words.is_a?(String)

      words.split(' ').select { |word| word.capitalize! || word }.join(' ')
    end

    # Cleans a word list.
    #
    # @param [String] words Space-separated words.
    # @raise [ArgumentError]
    #
    # @return [String] Words.
    def self.clean(words)
      raise ArgumentError, "This isn't a String." unless words.is_a?(String)
      
      words.gsub(/[^\p{L}\- ]/, '')
    end

  end

end
