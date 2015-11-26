###Interactive GIS Mapping for a Neighborhood Project



This interactive mapping tool was originally designed for a Seattle neighborhood project, to gather data from each participating neighbor about their experiences walking in the neighborhood:

* existing patterns of pedestrian circulation
* frequented destinations
* problem areas, safety issues
* opportunity zones

###Description of Mapping Tools
Web and database technologies include PostGIS, Mapserver, OpenLayers3, Ruby Mapscript, Ruby on Rails.

Shapefiles, high-resolution aerial photographs, and non-interactive database features are styled and served as WMS layers by Mapserver via CGI commands. A 'mapfile' containing specifications for a graphical map and data for display, used by Mapserver to retrieve and style layer images, is created on-the-fly at the server.  

WMS layers from remote servers such as openstreetmaps.org are also imported as base layer options.

Map features on **interactive layers** are served directly, via geoJSON, to an OpenLayers overlay with interactive drawing and editing tools.

An administrative user can edit and create new theme maps, assembling any number of layers and styling them for a particular purpose.



###More Detail on Mapping

Notes on how we create maps in this web application:

In practice, the easiest path to great-looking online maps is to design their appearance
in a desktop GIS application such as QGIS, export a mapfile from QGIS, snip the
individual layers from the mapfile, then use the snippets to create 'map_layers'
in this web application, where they can be further tweaked and used in many different maps.

Am migrating away from using mapfile text snippets stored in database, toward creating layers via parameters. One reason is to make the parameters easily editable. 

###Project Background
I was web communications consultant and member of the design team, funded by a Seattle Department of Neighborhoods Large Grant to study the area and plan an approach to understanding existing conditions and designing improvements to streets and paths. 

The other design team members were a landscape architect, a civil engineer, a community outreach specialist, and a finance specialist to research possible funding sources. 

