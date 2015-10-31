json.array!(@features) do |feature|
  json.extract! feature, :id, :name, :guid, :user_id, :share_type_id
  json.url feature_url(feature, format: :json)
end
