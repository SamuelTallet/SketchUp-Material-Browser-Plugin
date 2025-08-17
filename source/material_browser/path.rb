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

require 'erb'
require 'sketchup'

# Material Browser plugin namespace.
module MaterialBrowser

  # Path utilities.
  module Path

    # Converts a path to a file URI.
    #
    # @param [String] path
    # @raise [ArgumentError]
    #
    # @return [String] URI.
    def self.to_uri(path)
      raise ArgumentError, 'Path must be a String.' unless path.is_a?(String)

      # Fixes path only on Windows.
      path.gsub!('\\', '/') if Sketchup.platform == :platform_win

      uri = ERB::Util.url_encode(path)

      # Fixes URI only on Windows.
      uri.gsub!('%3A', ':') if Sketchup.platform == :platform_win

      uri.gsub!('%2F', '/')

      'file:///' + uri
    end

  end

end
