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
require 'extensions'

$LOAD_PATH.push(File.join(__dir__, 'material_browser', 'Libraries'))

# Material Browser plugin namespace.
module MaterialBrowser

  VERSION = '1.0.9'

  # Load translation if it's available for current locale.
  TRANSLATE = LanguageHandler.new('mbr.translation')
  # @see "material_browser/Resources/#{Sketchup.get_locale}/mbr.translation"

  # Remember extension name. See: `MaterialBrowser::Menu`.
  NAME = TRANSLATE['Material Browser']

  # Initialize session storage.
  # @todo Move these variables to `Model`, `SKM`, etc.
  SESSION = {
    model_materials: [],
    skm_files: [],
    th_materials: [],
  }

  # Register extension.

  extension = SketchupExtension.new(NAME, 'material_browser/load.rb')

  extension.version     = VERSION
  extension.creator     = 'Samuel Tallet'
  extension.copyright   = "© 2025 #{extension.creator}"

  extension_features = [

    TRANSLATE[
      'Search for SketchUp materials by name from three sources: active model, SKM collections and Texture Haven.'
    ],

    TRANSLATE['Filter materials by type (Brick, Wood, etc).'],

    TRANSLATE['Select material of your choice in one click.']

  ]

  extension.description = extension_features.join(' ')

  Sketchup.register_extension(extension, load_at_start = true)
  
end
