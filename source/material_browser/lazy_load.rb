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

require 'material_browser/model'
require 'material_browser/skm'
require 'material_browser/poly_haven'

# Material Browser plugin namespace.
module MaterialBrowser

  # Loads lazily plugin resources to speed up SketchUp startup.
  module LazyLoad

    # Before opening user interface:
    def self.before_ui_open
      # Ensures we are in sync with model materials.
      Model.export_materials_thumbnails

      # SKM files can be managed outside of SketchUp.
      # Better scan SKM folders again, this can avoid a restart.
      SKM.extract_thumbnails
      # @todo Remove outdated/unused SKM thumbnails from time to time.

      # Loads Poly Haven textures (once per SketchUp session).
      PolyHaven.load_textures if PolyHaven.textures.empty?
    end

  end

end
