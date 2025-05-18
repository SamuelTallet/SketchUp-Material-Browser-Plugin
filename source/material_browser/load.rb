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
require 'material_browser/settings'
require 'material_browser/app_observer'
require 'material_browser/materials_observer'
require 'material_browser/cache'
require 'material_browser/textures_cache'
require 'material_browser/materials_types'
require 'material_browser/model'
require 'material_browser/skm'
require 'material_browser/texture_haven'
require 'material_browser/menu'

# Material Browser plugin namespace.
module MaterialBrowser

  SESSION[:settings] = Settings.new

  # Settings are written when SketchUp closes.
  # See: `MaterialBrowser::AppObserver`.
  SESSION[:settings].read

  Sketchup.add_observer(AppObserver.new)
  Sketchup.active_model.materials.add_observer(MaterialsObserver.new)

  # If SketchUp was not properly closed:
  # removes previous active model's materials thumbnails directory.
  Model.remove_materials_thumbnails_dir

  # Maybe user migrated from an older version of Material Browser:
  # removes materials thumbs legacy directory.
  # @since 1.1.0
  Cache.remove_materials_thumbnails_dir

  # Downloaded textures can consume disk space, let's drop old ones!
  TexturesCache.delete_old

  SESSION[:materials_types] = MaterialsTypes.new

  Model.export_materials_thumbnails
  SKM.extract_thumbnails
  
  TextureHaven.catalog_materials

  # Plugs Material Browser menu into SketchUp UI.
  Menu.new(
    UI.menu('Plugins') # parent_menu
  )

  # Load complete.

end
