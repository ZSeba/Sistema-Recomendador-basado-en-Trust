class Trust 
  include Neo4j::ActiveRel
  property :score, type: Float
  property :from_user, type: String
  property :to_user, type: String

  from_class :User
  to_class   :User



end
