#Streetscapes.org#

An online '**social DESIGN networking**' tool with **interactive GIS maps**, database of participating **Neighbors** within a community, with links to a Nabble forum for design discussion and a wiki for creating content for reference such as design guidelines.

**Streetscapes.org** seeks to improve neighborhood community and cohesiveness, especially in the areas of pedestrian accessibility, emergency preparedness and identifying and linking needs with resources within communities.


##Interactive GIS Map Layers##

Using spatially-enabled Postgres database with **PostGIS, Mapserver, OpenLayers.js, and Ruby Mapscript**, locally hosted City of Seattle GIS map layers (shapefiles) are displayed. WMS layers from other servers such as Google Maps can be added as overlays. Logged-in users can create their own layers to be displayed over the other static layers.

##Project##

This is an on-going project: as community groups use the tool I will respond with new functionality to meet their needs. The current project (Greenwood.streetscapes.org) is for the Greenwood neighborhood in Seattle which lacks sidewalks and other infrastructure for safe pedestrian access, and which received a Seattle Department of Neighborhoods Matching Fund grant ($100k) to study the area and plan an approach to designing and implementing these improvements.

Link to the current online version of the [tool](http://greenwood.streetscapes.org).

Anyone who is interested in developing this type of planning tool, whether they be urban planners, landscape architects or software developers, are encouraged to dive in and help out with this open source project.


##To Do:##

* administrators create new thematic maps dynamically
    - ThemeMap.rb  :map_layers, :options,
    - MapLayer.rb  :map_entities, :options,  
    - MapEntity.rb :entity_type (polygon, polyline, point), :point_list, 
    - PolygonEntity << MapEntity, etc.  
* users create layers for these new thematic maps
* more CAD-like drawing functions - implement in MapEntity class hierarchy
* gemify the Mapserver/PostGIS functions
* gemify the MapEntity classes
* replace OpenLayers with Ruby Mapscript where possible, bypassing need to edit mapfiles by hand

