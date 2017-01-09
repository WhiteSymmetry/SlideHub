json.prettify!
json.array!(@slides) do |slide|
  json.extract! slide, 'id', 'user_id', 'name', 'description', 'category_id', 'key', 'extension', 'num_of_pages', 'created_at', 'category_name'
  json.extract! slide.user, 'username'
  json.thumbnail_url slide.thumbnail_url
  json.transcript_url slide.transcript_url
end
