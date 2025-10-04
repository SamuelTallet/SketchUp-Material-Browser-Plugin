# Material browser free plugin for SketchUp

Search for SketchUp materials by name from three sources: active model, local collections, and Poly Haven. Filter materials by type (Ceramic, Wood, etc). Select material of your choice in one click. Increase thumbnail up to 256px.

If you use SketchUp 2025 or newer, [Photoreal materials](https://help.sketchup.com/en/release-notes/sketchup-desktop-20250#photoreal) are supported, once you select a material from Poly Haven, Material Browser plugin will download and set all textures maps for you: AO, Diffuse, Metal, Normal GL, and Rough.

Screenshots
-----------

![SketchUp 2017 - Material Browser Plugin - Plugin View](https://github.com/SamuelTallet/SketchUp-Material-Browser-Plugin/raw/main/docs/screenshots/sketchup_2017-material_browser_plugin-plugin_view.webp)

![SketchUp 2025 - Material Browser Plugin - SketchUp View](https://github.com/SamuelTallet/SketchUp-Material-Browser-Plugin/raw/main/docs/screenshots/sketchup_2025-material_browser_plugin-sketchup_view.webp)

Installation
------------

1. Be sure to have SketchUp 2017 or newer.
2. Download latest Material Browser plugin from the [SketchUcation PluginStore](https://sketchucation.com/plugin/2365-material_browser).
3. Install plugin following this [guide](https://www.youtube.com/watch?v=tyM5f81eRno).

Now, you should have in SketchUp a "Material Browser" menu in "Extensions", and a "Material Browser" toolbar.

Help/FAQ
--------

### Can I bring my own materials?

Yes, this plugin does support custom materials as *.skm* files.

1. Open a model containing some of your materials.
2. Access SketchUp "Materials" tray.
3. Right-click on one of your materials then select "Save as".
4. Select a folder or subfolder to save this one as a *.skm* file.
5. Repeat previous steps with all your materials.  
6. In Material Browser, click on "SKM folder" icon at left.
7. Select top-level folder containing your *.skm* files.

Currently, only one custom SKM folder at once is supported.

### Materials list is too long. What can I do?

In Material Browser, click on eye icon then check "Display only In Model materials".

Thanks
------

[Poly Haven](https://polyhaven.com) for providing high-quality PBR textures through their API, for free.

On code side, this plugin relies on [Rubyzip](https://github.com/rubyzip/rubyzip), [Ruby backports](https://github.com/marcandre/backports), and [List.js](https://github.com/javve/list.js).

Heart icon is part of [Feather icons](https://www.iconfinder.com/iconsets/feather-5) from Iconfinder, and is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

Help icon was made by [graficon](https://www.iconfinder.com/graficon) from Iconfinder, and is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).


Copyright
---------

© 2025 Samuel Tallet
