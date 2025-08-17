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

require 'fileutils'
require 'sketchup'

# Material Browser plugin namespace.
module MaterialBrowser

  # Stores in a temporary directory downloaded materials textures.
  module TexturesCache

    # Absolute path to materials textures cache directory.
    #
    # @return [String]
    def self.path
      File.join(Sketchup.temp_dir, 'SketchUp MBR Plugin Textures')
    end

    # Removes materials textures cache directory.
    def self.remove_dir
      FileUtils.remove_dir(path) if Dir.exist?(path)
    end

    # Creates materials textures cache directory.
    def self.create_dir
      FileUtils.mkdir_p(path) unless Dir.exist?(path)
    end

    # Deletes all materials textures files older than a month stored in cache.
    #
    # Note: I think a month is on average "enough" time to work on same model.
    # Even if a same texture can be used on different models...
    def self.delete_old
      return unless Dir.exist?(path)

      one_month_ago = Time.now.to_i - 2_592_000 # seconds

      # Glob pattern to find all cached textures files.
      textures_glob_pattern = File.join(path, '*.{jpg,png}')

      # Fixes glob pattern only on Windows:
      textures_glob_pattern.gsub!('\\', '/')\
        if Sketchup.platform == :platform_win

      Dir.glob(textures_glob_pattern).each do |texture_file|

        if File.birthtime(texture_file).to_i < one_month_ago
          FileUtils.remove_file(texture_file)
        end

      end
    end

  end

end
