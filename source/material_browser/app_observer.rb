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
require 'material_browser/materials_observer'
require 'material_browser/user_interface'
require 'material_browser/model'
require 'material_browser/settings'
require 'material_browser/textures_cache'

# Material Browser plugin namespace.
module MaterialBrowser

  # Observes SketchUp events and reacts.
  class AppObserver < Sketchup::AppObserver

    # When SketchUp user creates a new, empty model:
    def onNewModel(model)
      model.materials.add_observer(MaterialsObserver.new)

      # No need to sync thumbnails if UI isn't open.
      if UserInterface.is_open?
        Model.export_materials_thumbnails
        UserInterface.reload
      end
    end

    # When SketchUp user opens an existing model:
    def onOpenModel(model)
      model.materials.add_observer(MaterialsObserver.new)

      if UserInterface.is_open?
        Model.export_materials_thumbnails
        UserInterface.reload
      end
    end

    # When SketchUp closes:
    def onQuit()
      Settings.current.write

      Model.remove_materials_thumbnails_dir

      # From time to time...
      if rand(30).zero?
        TexturesCache.delete_old
      end
    end

  end

end
