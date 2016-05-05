class Vote 
  include Neo4j::ActiveRel
  property :score, type: Integer
  property :voting_user, type: String
  property :from_user, type: String
  property :to_item, type: String

  from_class User
  to_class   Item

end
