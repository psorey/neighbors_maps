
APP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/config.yml")
require 'log_buddy'
require 'extensions/core'  # where 'String::dashed' is defined

LogBuddy.init

RGeo::ActiveRecord::SpatialFactoryStore.instance.tap do |config|
  # By default, use the GEOS implementation for spatial columns.
  #  config.default = RGeo::Geos.factory_generator
  # no, not getting Geos to work so try this:
  config.default = RGeo::Cartesian.simple_factory(srid: 3857)


  # But use a geographic implementation for point columns.
  #  config.register(RGeo::Geographic.spherical_factory(srid: 4326), geo_type: "point")
end

