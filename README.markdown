

#Streetscapes.org - Developing Web-Based Tools for Community Planning and Development#

The current project is an online '**social DESIGN networking**' tool with **interactive GIS maps**, database of participating **Neighbors** within a community, with links to a Nabble forum for design discussion and a wiki for creating content for reference such as design guidelines.

**Streetscapes.org** seeks to enhance urban neighborhood community and cohesiveness through participatory design of  improvements to street amenities (streetscapes!), public spaces, infrastructure, pedestrian access, and emergency preparedness. The current focus is on web-based tools to facilitate interactive design, de-mystify the public fundraising and permitting process, and to identify and link needs with resources within communities.


##Interactive GIS Map Layers##

Using spatially-enabled Postgres database with **PostGIS, [Mapserver](http://mapserver.org), [OpenLayers.js](http://openlayers.org), and Ruby Mapscript**, locally hosted City of Seattle GIS map layers (shapefiles) are displayed. WMS layers from other servers such as Google Maps can be added as overlays. Logged-in users can create their own layers to be displayed over the other static layers.

Currently the interactive mapping tool is being used in the Greenwood neighborhood of Seattle to gather walking data from Neighbors: existing patterns of pedestrian circulation, desire routes, problem spots and opportunity zones. When a significant amount of data from a cross-section of Neighbors has been gathered we will use the data to inform the choice of several north-south pedestrian connections and several east-west connections so that no one will have to walk more than one or two blocks to reach a paved path.


##Project##

This is an on-going project: as community groups use the tool we will respond with new functionality to meet their needs. The current project (Greenwood.streetscapes.org) is for the Greenwood neighborhood in Seattle which lacks sidewalks and other infrastructure for safe pedestrian access, and which received a Seattle Department of Neighborhoods Matching Fund grant ($100k) to study the area and plan an approach to designing and implementing these improvements.

Link to the current online version of the [Greenwood tool](http://greenwood.streetscapes.org).

Anyone interested in developing this type of planning tool, be they urban planners, landscape architects or software developers, are encouraged to dive in and help out with this open source project.


##To Do:##

* Administrators create new thematic maps dynamically (and refactor mapping functions accordingly):
    - ThemeMap.rb  :map_layers, {options},
    - MapLayer.rb  :geo_entities, {options}, 
    - GeoEntity.rb :entity_type (polygon, polyline, point), :point_list, {options}, 
    - GeoPolygonEntity << GeoEntity, etc.  
* Neighbors (users) create layers for these new thematic maps.
* CAD-like drawing functions - implement in MapEntity class hierarchy.
* Gemify Mapserver/PostGIS functions.
* Gemify GeoEntity classes.
* Replace OpenLayers.js functions with Ruby Mapscript where possible, bypassing need to edit mapfiles by hand.
* Implement geospatial needs/resources database and search functions (a whole new project, but related because
    of the use of PostGIS and Mapserver).
* Update to Rails 3.1.
* Tests! RSpec.

