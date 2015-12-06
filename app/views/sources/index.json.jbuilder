json.array!(@sources) do |source|
  json.extract! source, :id, :url, :wms_params, :source_type, :layer, :server_type
  json.url source_url(source, format: :json)
end
