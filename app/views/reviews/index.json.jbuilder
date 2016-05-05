json.array!(@reviews) do |review|
  json.extract! review, :id, :stars, :content, :from_user, :to_item
  json.url review_url(review, format: :json)
end
