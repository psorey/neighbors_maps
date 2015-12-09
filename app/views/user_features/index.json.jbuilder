json.array!(@user_features) do |user_feature|
  json.extract! user_feature, :id, :map_layer_id, :user_id, :name, :text, :number, :amount
  json.url user_feature_url(user_feature, format: :json)
end
