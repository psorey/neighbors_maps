require 'bluecloth'

class WelcomeController < ApplicationController
  
  def write_project_markdown
    project_markdown
    @string = @str1 + @str2 + @str3 + @str4
  end


  def index
    project_markdown
  end


  def project_markdown
@str1 = <<-STRING

##Interactive Web Mapping 
### Neighborhood Planning Tool 
This interactive mapping tool began with a Seattle neighborhood project, planning pedestrian and bicycle path improvements for the Greenwood neighborhood. We wanted to gather data from every household about how people walk and bike in the neighborhood. We wanted to collect and publish data about:

* existing patterns of pedestrian and bicycle circulation,
* frequented destinations,
* problem areas, safety issues,

to find opportunities for making improvements to pedestrian and bicycle infrastructure, and to establish a hierarchy of needs for deciding how to use limited resources for the best outcome.

STRING


@intro = BlueCloth.new(@str1).to_html()


@str2 = <<-STRING

###Description of Technology 

Web and database open source technologies include:

* [PostGIS](http://postgis.org) and Postgresql
* [Mapserver](http://mapserver.org) and Ruby Mapscript
* [OpenLayers3](http://openlayers.org) client-side map display library
* [Ruby on Rails](http://rubyonrails.org) web application framework
* Ubuntu Linux / Apache server

Click [here](http://github.com/psorey/neighbors_maps "Paul Sorey's Github account: Ruby, Javascript, HTML, CSS") to see the code at Gihub.

Shapefiles, high-resolution aerial photographs, and non-interactive database features are styled and served as WMS layers by Mapserver via CGI commands. A *mapfile* containing specifications for a graphical map and data for display, used by Mapserver to retrieve and style layer images, is created on-the-fly at the server.  

WMS layers from remote servers such as openstreetmaps.org are also imported as base layer options.

User-created map features on **interactive layers** are served directly, via geoJSON, to an OpenLayers vector layer with interactive drawing and editing tools.

An administrative user can edit and create new theme maps, assembling any number of layers and styling them for a particular purpose.

STRING


@technology = BlueCloth.new(@str2).to_html()


@str3 = <<-STRING

###How Maps are Created

In practice, the easiest path to great-looking online maps is to design their appearance
in a desktop GIS application such as QGIS, export a mapfile from QGIS, snip the
individual layers from the mapfile, then use the snippets to create 'map_layers'
in this web application, where they can be further tweaked and used in many different maps.

###Interactive Layers

Each registered user can populate their own layers with requested information. For *Walking Paths*, the user's residence is shown; the user draws the actual routes taken from their residence, and frequency of trips.  User layers can be edited only by the user. Administrators can combine all users' data from a survey, apply number-crunching algorithms, and generate, say, a heatmap showing the most heavily-used routes.



###To Do

* Migrate away from using mapfile text snippets, toward creating layers via parameters. One reason is to make the parameters easily editable.
* Enable administrators to design and implement interactive survey layers.

STRING


@more_detail = BlueCloth.new(@str3).to_html()



@str4 = <<-STRING

###Greenwood Neighborhood Project Background
I was web communications consultant and member of the design team, funded by a Seattle Department of Neighborhoods Large Grant to study the Greenwood neighborhood and plan an approach to understanding existing conditions and designing improvements to streets and paths.

The other design team members were a landscape architect, a civil engineer, a community outreach specialist, and a finance specialist to research possible funding sources. 

###Next Steps
* Work with the City to define a hierarchy of path-types from crushed-rock to standard City sidewalks with curb and gutter
* Find or organize a neighborhood-based group to work with
* Find a non-profit organization willing to sponsor
* Apply for another Department of Neighborhoods Large Matching Grant
* Train volunteers to assist neighbors entering data
* Gather the data
* Analyze the data and publish results
* Generate recommendations for development strategy

STRING


@project_background = BlueCloth.new(@str4).to_html()

  end

end
  
