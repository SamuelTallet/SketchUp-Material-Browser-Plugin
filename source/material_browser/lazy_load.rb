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
require 'material_browser/model'
require 'material_browser/settings'
require 'material_browser/skm'
require 'material_browser/poly_haven'

# Material Browser plugin namespace.
module MaterialBrowser

  # Loads lazily plugin resources to speed up SketchUp startup.
  module LazyLoad

    # Before opening user interface:
    def self.before_ui_open
      Sketchup.status_text = TRANSLATE['Loading Material Browser...']

      # Always ensures we are in sync with model materials.
      Model.export_materials_thumbnails

      # SKM files can be managed outside of SketchUp.
      # So let's scan again SKM folders according to display settings.
      # And sometimes, cleanups thumbnails directory.

      if Settings.current.display_custom_skm? && !Settings.current.custom_skm_path.empty?
        SKM.extract_thumbnails(:custom, then_cleanup: rand(15).zero?)
      end

      if Settings.current.display_profile_skm?
        SKM.extract_thumbnails(:profile, then_cleanup: rand(15).zero?)
      end

      if Settings.current.display_builtin_skm?
        SKM.extract_thumbnails(:builtin, then_cleanup: rand(30).zero?)
      end

      # Loads Poly Haven textures, also according to display settings.
      # But once per SketchUp session since textures list is static.
      if Settings.current.display_poly_haven? && PolyHaven.textures.empty?
        PolyHaven.load_textures
      end

      Sketchup.status_text = nil
    end

  end

end
