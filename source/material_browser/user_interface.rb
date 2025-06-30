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

require 'cgi'
require 'sketchup'
require 'material_browser/html_dialogs'
require 'material_browser/settings'
require 'material_browser/fs'
require 'material_browser/model'
require 'material_browser/skm'
require 'material_browser/poly_haven'

# Material Browser plugin namespace.
module MaterialBrowser

  # Allows to search for SketchUp materials by name.
  class UserInterface

    # Placeholder of HTML Dialog instance used during whole SketchUp session.
    # Not to be confused with `@html_dialog`
    # @type [UI::HtmlDialog, nil]
    @@html_dialog = nil

    @@is_open = false

    # Indicates whether Material Browser UI (underlying HTML Dialog) is open.
    def self.is_open?
      @@is_open
    end

    # Opens Material Browser UI.
    # If already open, brings it to front.
    def self.open

      if @@is_open
        raise 'HTML Dialog instance is missing.' if @@html_dialog.nil?

        @@html_dialog.bring_to_front
      else
        self.new.show
      end

    end

    # Material Browser UI HTML code.
    #
    # @return [String]
    def self.html

      HTMLDialogs.merge(

        # Note: Paths below are relative to `HTMLDialogs::DIR`.
        document: 'user-interface.rhtml',
        scripts: [
          'libraries/list.js',
          'user-interface.js'
        ],
        styles: [
          'user-interface.css'
        ]
  
      )

    end

    # Reloads Material Browser UI.
    #
    # @return [Boolean]
    def self.reload

      if @@is_open
        raise 'HTML Dialog instance is missing.' if @@html_dialog.nil?

        @@html_dialog.set_html(html)

        return true
      end

      false

    end

    # Builds Material Browser UI.
    def initialize
      @html_dialog = create_html_dialog
      @@html_dialog = @html_dialog
      # Keeps a reference to HTML Dialog instance. Cf. `self.open`

      fill_html_dialog
      configure_html_dialog
    end

    # Shows Material Browser UI.
    def show
      @html_dialog.show

      @@is_open = true
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
    private def fill_html_dialog
      @html_dialog.set_html(self.class.html)
    end

    # Configures HTML dialog.
    private def configure_html_dialog

      @html_dialog.add_action_callback('setZoomValue') do |_ctx, zoom_value|
        Settings.current.zoom_value = zoom_value
      end

      @html_dialog.add_action_callback('setDisplayName') do |_ctx, display_name|
        Settings.current.display_name = display_name
      end

      @html_dialog.add_action_callback('setDisplaySource') do |_ctx, display_source|
        Settings.current.display_source = display_source
      end

      @html_dialog.add_action_callback('setDisplayOnlyModel') do |_ctx, display_only_model|

        Settings.current.display_only_model = display_only_model

        self.class.reload

      end

      @html_dialog.add_action_callback('setCustomSKMPath') do |_ctx|

        Settings.current.custom_skm_path = UI.select_directory.to_s

        SKM.remove_thumbnails_dir
        SKM.extract_thumbnails

        self.class.reload

      end

      @html_dialog.add_action_callback('setTypeFilterValue') do |_ctx, type_filter_value|
        Settings.current.type_filter_value = type_filter_value
      end

      @html_dialog.add_action_callback('selectModelMaterial') do |_ctx, model_material_name|
        Model.select_material(model_material_name)
      end

      @html_dialog.add_action_callback('selectSKMFile') do |_ctx, skm_file_path|
        SKM.select_file(skm_file_path)
      end

      @html_dialog.add_action_callback('selectPolyHavenTexture') do |_ctx, ph_texture_slug|
        PolyHaven.select_texture(ph_texture_slug)
      end

      @html_dialog.add_action_callback('openURL') do |_ctx, url|
        UI.openURL(url)
      end

      @html_dialog.set_on_closed { @@is_open = false }

      @html_dialog.center

    end

  end

end
