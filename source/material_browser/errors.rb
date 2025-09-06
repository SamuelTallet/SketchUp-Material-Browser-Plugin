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

# Material Browser plugin namespace.
module MaterialBrowser

  # Error helper.
  module Errors

    # Displays an error message with debug information.
    #
    # @param message [String] Error message.
    # @param cause [Exception, nil] Optional source error.
    def self.display(message, cause: nil)
      if cause.is_a?(Exception)
        message = "#{message} because:\n#{cause.message}\n\n"
        message += "Backtrace:\n#{cause.backtrace.join("\n")}"
      end

      UI.messagebox(
        "Material Browser plugin error: #{message}\n\n" \
        "Versions:\n" \
        "Material Browser #{VERSION}\n" \
        "SketchUp 20#{Sketchup.version}"
      )
    end

  end

end
