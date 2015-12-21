json.array!(@ol3_vector_styles) do |ol3_vector_style|
  json.extract! ol3_vector_style, :id, :name, :alias, :stroke_width, :font_size, :stroke_color, :font_color, :fill_color, :style_type
  json.url ol3_vector_style_url(ol3_vector_style, format: :json)
end
