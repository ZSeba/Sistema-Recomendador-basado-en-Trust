json.array!(@trusts) do |trust|
  json.extract! trust, :id, :score
  json.url trust_url(trust, format: :json)
end
