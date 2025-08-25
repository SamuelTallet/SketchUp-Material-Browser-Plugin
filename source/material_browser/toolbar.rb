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

  # Plugin toolbar.
  class Toolbar

    # Absolute path to icons.
    ICONS_PATH = File.join(__dir__, 'Toolbar Icons').freeze

    private_constant :ICONS_PATH

    # Initializes instance.
    def initialize
      @toolbar = UI::Toolbar.new(NAME)
      # Icon extension depending on platform.
      # PDF on macOS, SVG on Windows.
      @icon_extension = Sketchup.platform == :platform_osx ? 'pdf' : 'svg'
    end

    # Returns icon file for a command.
    # @param [String] command
    #
    # @return [String] Absolute path to icon.
    private def icon_file(command)
      File.join(ICONS_PATH, "#{command}.#{@icon_extension}")
    end

    # Defines and returns "Open Material Browser..." command.
    private def omb_command
      command = UI::Command.new('omb') do
        LazyLoad.before_ui_open
        UserInterface.open
      end

      command.small_icon = icon_file('omb')
      command.large_icon = icon_file('omb')
      command.tooltip = TRANSLATE['Open Material Browser...']
      command.status_bar_text = TRANSLATE[
        'BTW, thanks to Poly Haven for providing free textures'
      ] + ' <3'

      command
    end

    # Prepares and returns toolbar.
    def prepare
      @toolbar.add_item(omb_command)
    end

  end

end
