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
  

end
