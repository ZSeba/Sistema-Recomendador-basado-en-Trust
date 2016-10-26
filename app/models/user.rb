class User
  include Neo4j::ActiveNode
  property :name, type: String
  property :test_ranking, type: String
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
    #binding.pry
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

  def recommend
    @tags = Tag.all
    @user = self

    @items = Item.all

    @all_items = Array.new

    @items.each do |itm|
      @all_items.append(itm.name)
    end
    if @all_items.any?
      @predicted_scores = Array.new
      @all_reviews = Array.new
      @all_reviews = @user.reviews.each_rel{|r| }
      @items_reviewed = Array.new

      @all_reviews.each do |rev|
        @items_reviewed.append(rev.to_node.name)
      end

      @not_reviewed = @all_items - @items_reviewed
      @not_reviewed.each do |notr|
        @auux = Array.new
        @auux.append(notr)
        score = predict_user_score(notr)
        if score > 0
          @auux.append(score)
          @predicted_scores.append(@auux)
        end

        return @predicted_scores

      end
    end
  end

  def predict_user_score(item)
    #@neighbourhood_limit = 3

    #DEFINIR A QUIEN SE PREDICE PUNTAJE
    @consumer = self

    #DEFINIR A QUE ITEM SE LE VA A PREDECIR EL PTJE
    @da_item = Item.find_by(name: item)

    #TODAS LAS REVIEWS DEL OBJETO QUE SE PREDICE, PARA SABER QUÉ USUARIOS LO VIERON
    @reviewz = @da_item.reviews.each_rel{|r| }

    #CON LAS REVIEWS, SE SABE QUIENES SON LOS PRODUCTORES PARA ESTA SESION, AHORA SE OBTIENEN TODAS LAS QUE ESCRIBIO CADA USUARIO
    @userz = Array.new
    @reviewz.each do |review|
      @userz.push(review.from_node)
    end

    @consumer_array = Array.new

    #AHORA VER TODAS LAS REVIEWS DEL USUARIO CONSUMIDOR
    @consumer_reviews = @consumer.reviews.each_rel{|r| }
    @consumer_reviews.each do |review|
      @aux2 = Array.new
      @aux2.push(review.stars,review.to_node.name)
      @consumer_array.push(@aux2)
    end
    consum_sum = 0
    @consumer_array.each do |consum|
      consum_sum = consum_sum + consum[0].to_f
    end
    @consumer_average = consum_sum/@consumer_array.size.to_f

    #SE HACE UN ARREGLO "producers" CON (USUARIO,ITEM,ESTRELLAS) PARA SABER LAS QUE TIENE EN COMÚN CON EL CONSUMIDOR
    @producers = Array.new
    @producers_averages = Array.new
    @userz.each do |user|
      @aux = Array.new
      #if @consumer.trusts.each_rel.select{ |r| r.to_user == @user.name }.empty? || @consumer.trusts.each_rel.select{ |r| r.to_user == @user.name }.first.score >= 0.5
      @reviewz_by_user = user.reviews.each_rel{|r| }
      @reviewz_by_user.each do |user_review|
        @aux2 = Array.new
        @aux2.push(user_review.from_node.name,user_review.to_node.name,user_review.stars)
        @aux.push(@aux2)
      #end
      @producers.push(@aux)
      end
    end

    #SE CALCULA EL PROMEDIO DE LAS REVIEWS DE CADA USUARIO
    @producers_averages = Array.new
    @producers.each do |producer|
      @count = 0
      producer.each do |review|
        @count = @count + review[2].to_f
      end
      @aux = Array.new
      @average = @count / producer.size.to_f
      @aux.push(producer[0][0],@average)
      @producers_averages.push(@aux)
    end

    #SE CREAN LOS ARRAYS QUE VAN A TENER LAS REVIEWS QUE TIENE CADA PRODUCTOR CON EL CONSUMIDOR
    @producers_array = Array.new
    @producers.each do |purodyusa|
      @aux2 = Array.new
      purodyusa.each do |purodyusa_riviu|
        @flag = 0
        @consumer_array.each do |consyuma|
          if purodyusa_riviu[1] == consyuma[1]
            @flag = 1
          end
        end
        if @flag == 1
          @aux = Array.new
          @aux.push(purodyusa_riviu[0],purodyusa_riviu[1],purodyusa_riviu[2])
          @aux2.push(@aux)
        end
      end
      #NO SIRVE SI SOLO TIENEN UNA REVIEW EN COMUN ...
      if @aux2.length > 1
        @producers_array.push(@aux2)
      end
      #@producers_array.push(@aux2)
    end

    @pearson_array = Array.new
    #CALCULAR EL PEARSON DE CADA DUPLA PRODUCTOR-CONSUMIDOR
      @debugg = Array.new
    @producers_array.each do |purodyu|
      @numeric_array_cons = Array.new
      @numeric_array_prod = Array.new

      purodyu.each do |yusa|

        @numeric_array_cons.append(yusa[2].to_f)

        @consumer_array.each do |consyu|
          if consyu[1] == yusa[1]
            @numeric_array_prod.append(consyu[0].to_f)
          end
        end
        @debugg.append(@numeric_array_prod)
      end

        if @numeric_array_prod.length > 1


          @aux = Array.new
          @aux.append(@numeric_array_cons)
          @aux.append(@numeric_array_prod)

          @pearson = Statsample::Bivariate::Pearson.new(@numeric_array_cons.to_scale,@numeric_array_prod.to_scale)

          @hola = @pearson.r

          if @pearson.r <1 || @pearson.r > -1
          
            @aux = Array.new
          
            @aux.append(purodyu[0][0])
            @aux.append(@pearson.r)
          

            @pearson_array.append(@aux)
          end

        end
      end


    @score_target_array = Array.new
    #crear array con score al item correspondiente - promedio por correlacion

    @producers.each do |purodyyu|
      purodyyu.each do |reviu|

        if reviu[1] == @da_item.name
          @aux = Array.new
          @aux.append(reviu[0])
          @aux.append(reviu[2])
          @score_target_array.append(@aux)
        end
      end 
    end 


    @denom_array = Array.new
    ##for denom restas 
    #  denom.push( (score_target[index]-producers_averages[index]) * pearson_array[index])
    #end

    index = 0.0
    $limit = @pearson_array.length.to_f;

    while index < $limit  do
      resta = @score_target_array[index][1].to_f - @producers_averages[index][1].to_f
      @denom_array.append(resta *@pearson_array[index][1].to_f)
      index = index + 1
    end

    @denom = 0
    @denom_array.each do |denoma|
      @denom = @denom + denoma 
    end

    @num = 0
    @pearson_array.each do |perso|
      @num = @num + perso[1].abs
    end
    if @num == 0
      @num = 1
    end
    @delta = @denom/@num
    @pred_score = @consumer_average + @delta

    return @pred_score

  end
end
