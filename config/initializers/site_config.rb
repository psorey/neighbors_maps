
APP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/config.yml")

require 'extensions/core'  # where 'String::dashed' is defined
