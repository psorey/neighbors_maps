json.array!(@vector_features) do |vector_feature|
  json.extract! vector_feature, :id, :name, :text, :vector_type, :amount, :number, :guid
  json.url vector_feature_url(vector_feature, format: :json)
end
