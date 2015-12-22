class Ol3VectorStyle < ActiveRecord::Base

  def default_style
    @fill_color = "#ffffff88"
    @stroke_color = '#3399CC'
    @stroke_width = 1.25
    @image_style = "Circle"
    @image_style_radius = 10
    @image_style_fill_color = "#aabbff88"
  end

end



=begin

// default styles...
 var fill = new ol.style.Fill({
   color: 'rgba(255,255,255,0.4)'
 });
 var stroke = new ol.style.Stroke({
   color: '#3399CC',
   width: 1.25
 });
 var styles = [
   new ol.style.Style({
     image: new ol.style.Circle({
       fill: fill,
       stroke: stroke,
       radius: 5
     }),
     fill: fill,
     stroke: stroke
   })
 ];


A separate editing style has the following defaults:

 var white = [255, 255, 255, 1];
 var blue = [0, 153, 255, 1];
 var width = 3;
 styles[ol.geom.GeometryType.POLYGON] = [
   new ol.style.Style({
     fill: new ol.style.Fill({
       color: [255, 255, 255, 0.5]
     })
   })
 ];
 styles[ol.geom.GeometryType.MULTI_POLYGON] =
     styles[ol.geom.GeometryType.POLYGON];
 styles[ol.geom.GeometryType.LINE_STRING] = [
   new ol.style.Style({
     stroke: new ol.style.Stroke({
       color: white,
       width: width + 2
     })
   }),
   new ol.style.Style({
     stroke: new ol.style.Stroke({
       color: blue,
       width: width
     })
   })
 ];
 styles[ol.geom.GeometryType.MULTI_LINE_STRING] =
     styles[ol.geom.GeometryType.LINE_STRING];
 styles[ol.geom.GeometryType.POINT] = [
   new ol.style.Style({
     image: new ol.style.Circle({
       radius: width * 2,
       fill: new ol.style.Fill({
         color: blue
       }),
       stroke: new ol.style.Stroke({
         color: white,
         width: width / 2
       })
     }),
     zIndex: Infinity
   })
 ];
 styles[ol.geom.GeometryType.MULTI_POINT] =
     styles[ol.geom.GeometryType.POINT];
 styles[ol.geom.GeometryType.GEOMETRY_COLLECTION] =
     styles[ol.geom.GeometryType.POLYGON].concat(
         styles[ol.geom.GeometryType.POINT]
     );

=end
