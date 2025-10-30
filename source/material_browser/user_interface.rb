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
require 'material_browser/path'
require 'material_browser/model'
require 'material_browser/skm'
require 'material_browser/poly_haven'
require 'material_browser/errors'

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
          'libraries/tip.css',
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

        # @todo Reload only affected items.
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

        # Unless user resized HTML dialog,
        # this displays a 4x3 grid of thumbnails,
        # assuming 160 as current zoom value.
        # See: `Settings::DEFAULT_ZOOM_VALUE`.
        width:           675,
        height:          500,

        # When user reduces dialog at minimum,
        # this displays a 3x3 grid of thumbnails,
        # assuming 160 as current zoom value.
        min_width:       525,
        min_height:      500
      )

    end

    # Fills HTML dialog.
    private def fill_html_dialog
      @html_dialog.set_html(self.class.html)
    end

    # Shows loading screen within HTML dialog.
    private def show_loading_screen
      @html_dialog.execute_script('MaterialBrowser.showLoadingScreen()')
    end

    # Hides loading screen within HTML dialog.
    private def hide_loading_screen
      @html_dialog.execute_script('MaterialBrowser.hideLoadingScreen()')
    end

    # Configures HTML dialog.
    private def configure_html_dialog

      @html_dialog.add_action_callback('setZoomValue') do |_ctx, zoom_value|
        Settings.current.zoom_value = zoom_value
      end

      @html_dialog.add_action_callback('setAlwaysDisplayName') do |_ctx, display_name|
        Settings.current.always_display_name = display_name
      end

      @html_dialog.add_action_callback('setDisplaySources') do |_ctx, dcs, dps, dbs, dph|
        Settings.current.display_custom_skm = dcs
        Settings.current.display_profile_skm = dps
        Settings.current.display_builtin_skm = dbs
        Settings.current.display_poly_haven = dph

        show_loading_screen
        SKM.extract_thumbnails(:custom) if dcs && !Settings.current.custom_skm_path.empty?
        SKM.extract_thumbnails(:profile) if dps
        SKM.extract_thumbnails(:builtin) if dbs

        PolyHaven.load_textures if dph && PolyHaven.textures.empty?

        self.class.reload
      end

      @html_dialog.add_action_callback('setCustomSKMPath') do |_ctx|
        dir_selected = UI.select_directory

        if dir_selected.is_a?(String)
          Settings.current.custom_skm_path = dir_selected

          show_loading_screen
          SKM.extract_thumbnails(:custom)

          # We force display of custom SKMs to prevent user from losing sight of them.
          Settings.current.display_custom_skm = true

          self.class.reload
        end
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
        begin
          show_loading_screen
          # FIXME: Loading screen doesn't last on SketchUp 2017.
          if Sketchup.version.to_i == 17
            Sketchup.status_text = "#{NAME} - #{TRANSLATE['Loading...']}"
          end

          PolyHaven.select_texture(ph_texture_slug)
        rescue => error
          Errors.display("Can't select texture", cause: error)
        ensure
          hide_loading_screen
          Sketchup.status_text = nil if Sketchup.version.to_i == 17
        end
      end

      @html_dialog.add_action_callback('openURL') do |_ctx, url|
        UI.openURL(url)
      end

      @html_dialog.set_on_closed { @@is_open = false }

      @html_dialog.center

    end

  end

end
