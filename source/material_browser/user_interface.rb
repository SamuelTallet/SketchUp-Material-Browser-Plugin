# Material Browser (MBR) extension for SketchUp 2017 or newer.
# Copyright: © 2021 Samuel Tallet <samuel.tallet arobase gmail.com>
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
require 'material_browser/html_dialogs'
require 'material_browser/model'
require 'material_browser/skm'
require 'material_browser/texture_haven'

# Material Browser plugin namespace.
module MaterialBrowser

  # Allows to search for SketchUp materials by name.
  class UserInterface

    # Is it safe to open Material Browser UI right now?
    #
    # @return [Boolean]
    def self.safe_to_open?

      if SESSION[:html_dialog_open?]

        UI.messagebox(TRANSLATE['Material Browser UI is already open.'])
        return false

      end

      true

    end

    # Shows Material Browser UI if all good conditions are met.
    #
    # @return [nil]
    def self.safe_show

      self.new.show if safe_to_open?

      nil

    end

    # Reloads Material Browser UI.
    #
    # @return [Boolean]
    def self.reload

      if SESSION[:html_dialog_open?]

        raise 'UI HTML Dialog instance is missing.' if SESSION[:html_dialog].nil?

        SESSION[:html_dialog].set_html(HTMLDialogs.merge(

          # Note: Paths below are relative to `HTMLDialogs::DIR`.
          document: 'material-browser.rhtml',
          scripts: [
            'lib/list.js',
            'material-browser.js'
          ],
          styles: [
            'material-browser.css'
          ]
  
        ))

        return true

      end

      false

    end

    # Builds Material Browser UI.
    def initialize

      @html_dialog = create_html_dialog

      SESSION[:html_dialog] = @html_dialog

      fill_html_dialog

      configure_html_dialog

    end

    # Shows Material Browser UI.
    #
    # @return [void]
    def show

      @html_dialog.show

      # Material Browser UI is open.
      SESSION[:html_dialog_open?] = true

    end

    # Creates SketchUp HTML dialog that powers Material Browser UI.
    #
    # @return [UI::HtmlDialog] HTML dialog.
    private def create_html_dialog

      UI::HtmlDialog.new(
        dialog_title:    NAME,
        preferences_key: 'MBR',
        scrollable:      true,
        width:           510,
        height:          490,
        min_width:       510,
        min_height:      490
      )

    end

    # Fills HTML dialog.
    #
    # @return [nil]
    private def fill_html_dialog

      @html_dialog.set_html(HTMLDialogs.merge(

        # Note: Paths below are relative to `HTMLDialogs::DIR`.
        document: 'material-browser.rhtml',
        scripts: [
          'lib/list.js',
          'material-browser.js'
        ],
        styles: [
          'material-browser.css'
        ]

      ))

      nil

    end

    # Configures HTML dialog.
    #
    # @return [nil]
    private def configure_html_dialog

      @html_dialog.add_action_callback('selectModelMaterial') do |_ctx, model_material_name|
        Model.select_material(model_material_name)
      end

      @html_dialog.add_action_callback('selectSKMFile') do |_ctx, skm_file_path|
        SKM.select_file(skm_file_path)
      end

      @html_dialog.add_action_callback('selectTHMaterial') do |_ctx, th_material|
        TextureHaven.select_material(th_material)
      end

      @html_dialog.set_on_closed { SESSION[:html_dialog_open?] = false }

      @html_dialog.center

      nil

    end

  end

end
