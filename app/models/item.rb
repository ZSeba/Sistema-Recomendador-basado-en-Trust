class Item 
  include Neo4j::ActiveNode
  property :name, type: String ,constraint: :unique
  property :description, type: String
  property :picture_url, type: String

  has_many :in, :reviews, rel_class: :Review

  has_many :in, :tags, origin: :items

  def avg_rating
    sum = 0.0
    reviews = self.reviews.each_rel{|r|}
    reviews.each do |rev|
      sum = sum + rev.stars.to_f

    end
    @avg_rating = sum/self.reviews.count
  end

  def self.get_test_sample
    outdoors_tag = Tag.find_by(name: "Aire Libre")
    snow_tag = Tag.find_by(name: "Nieve")
    urban_tag = Tag.find_by(name: "Urbano")
    historic_tag = Tag.find_by(name: "Histórico")
    artistic_tag = Tag.find_by(name: "Artístico")

    outdoors = outdoors_tag.items
    snow = snow_tag.items
    urban = urban_tag.items
    historic = historic_tag.items
    artistic = artistic_tag.items

    sample = []
    [outdoors,snow,urban,historic,artistic].each do |tag|
      random_item = tag[rand(0..tag.size-1)]
      added_to_sample = 0

      until (added_to_sample == 2) do
        unless sample.include? random_item
          sample << random_item
          added_to_sample += 1
        else
          random_item = tag[rand(0..tag.size-1)]
        end
      end
    end
    return sample
  end

end
