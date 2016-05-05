class User
  include Neo4j::ActiveNode
  property :name, type: String
  property :password_hash, type: String
  property :password_salt, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  has_many :out, :reviews, rel_class: :Review
  has_many :out, :trusts, rel_class: :Trust
  has_many :out, :votes, rel_class: :Vote

  attr_accessor :password
  validates_confirmation_of :password
  before_save :encrypt_password

  def encrypt_password
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  end

  def self.authenticate(name, password)
    user = User.where(name: name).first
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end
  def match_password(login_password="")
   if login_password == @user.password
     true
   else
     false
   end
  end
end
