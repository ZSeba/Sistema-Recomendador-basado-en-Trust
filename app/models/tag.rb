class Tag 
  include Neo4j::ActiveNode
  property :name, type: String

  has_many :out, :items, type: 'tagged_item'


end
