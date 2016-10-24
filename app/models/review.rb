class Review
  include Neo4j::ActiveRel


  from_class :User
  to_class   :Item
  property :stars, type: String
  property :content, type: String
  property :from_user, type: String
  property :to_item, type: String



end
