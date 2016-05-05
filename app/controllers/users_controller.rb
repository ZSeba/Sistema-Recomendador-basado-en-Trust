class UsersController < ApplicationController
  #before_action :set_user, only: [:show, :edit, :update, :destroy]
  #before_filter :save_login_state, :only => [:new, :create]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    #binding.pry
    @user = User.create(params[:user])
    if @user.save
      flash[:notice] = "Welcome to the site!"
      redirect_to users_recommend_path
    else
      flash[:alert] = "There was a problem creating your account. Please try again."
      redirect_to :back
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def recommend
    @tags = Tag.all

    if current_user != nil
      @user = current_user
    else
      @user = User.first
    end

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
        @auux.append(predict_user_score(notr))
        @predicted_scores.append(@auux)
      end
    end
  end

  def predict_user_score(item)
    @neighbourhood_limit = 3

    #DEFINIR A QUIEN SE PREDICE PUNTAJE
    if current_user != nil
    @consumer = current_user
    else
      @consumer = User.first
    end

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

    @producers = Array.new
    @producers_averages = Array.new

    #SE HACE UN ARREGLO "producers" CON (USUARIO,ITEM,ESTRELLAS) PARA SABER LAS QUE TIENE EN COMÚN CON EL CONSUMIDOR
    @userz.each do |user|
      @aux = Array.new

      if @consumer.trusts.each_rel.select{ |r| r.to_user == @user.name }.empty? || @consumer.trusts.each_rel.select{ |r| r.to_user == @user.name }.first.score >= 0.5
      @reviewz_by_user = user.reviews.each_rel{|r| }
      @reviewz_by_user.each do |user_review|

        @aux2 = Array.new
        @aux2.push(user_review.from_node.name,user_review.to_node.name,user_review.stars)
        @aux.push(@aux2)

      end

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

    @producers_array = Array.new

    #SE CREAN LOS ARRAYS QUE VAN A TENER LAS REVIEWS QUE TIENE CADA PRODUCTOR CON EL CONSUMIDOR
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

    @delta = @denom/@num


    @pred_score = @consumer_average + @delta

    return @pred_score

  end


  def upvote

    current_item= Item.find_by(id: user_params[:current_item])
    user = User.find_by(name: current_user.name)
    target_user = User.find_by(name: user_params[:target_user])

    @user_upvotes = Trust.where(from_user: user.name)

    @result = Array.new

    @user_upvotes.each do |le_coso|
      if le_coso.to_user == target_user.name
        @result.append(le_coso)
      end
    end

    #render :text => @result.inspect
    if @result.empty?

      new_vote = Vote.new(voting_user: user.name, from_node: target_user,to_node: current_item, from_user: target_user.name,to_item:current_item.name )
      new_vote.save
      new_trust = Trust.new(score: '0.5',from_node: user,to_node: target_user, from_user: user.name, to_user: target_user.name)
      respond_to do |format|
        if new_trust.save
          format.html { redirect_to current_item, notice: 'Trust was successfully created.' }
          format.json { render :show, status: :created, location: @review }
        else
          format.html { render :new }
          format.json { render json: user.errors, status: :unprocessable_entity }
        end
      end
    else
      newscore = @result[0].score+0.1
      new_vote = Vote.new(voting_user: user.name, from_node: target_user,to_node: current_item, from_user: target_user.name,to_item:current_item.name )
      new_vote.save

      respond_to do |format|
        if @result[0].update(score: newscore)
          format.html { redirect_to current_item, notice: 'Trust was successfully updated.' }
          format.json { render :show, status: :created, location: @review }
        else
          format.html { render :edit }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end




  end

  def downvote

    current_item= Item.find_by(id: user_params[:current_item])
    user = User.find_by(name: current_user.name)
    target_user = User.find_by(name: user_params[:target_user])

    @user_upvotes = Trust.where(from_user: user.name)

    @result = Array.new

    @user_upvotes.each do |le_coso|
      if le_coso.to_user == target_user.name
        @result.append(le_coso)
      end
    end

    #render :text => @result.inspect
    if @result.empty?

      new_vote = Vote.new(voting_user: user.name, from_node: target_user,to_node: current_item, from_user: target_user.name,to_item:current_item.name )
      new_vote.save
      new_trust = Trust.new(score: '0.5',from_node: user,to_node: target_user, from_user: user.name, to_user: target_user.name)
      respond_to do |format|
        if new_trust.save
          format.html { redirect_to current_item, notice: 'Trust was successfully created.' }
          format.json { render :show, status: :created, location: @review }
        else
          format.html { render :new }
          format.json { render json: user.errors, status: :unprocessable_entity }
        end
      end
    else
      newscore = @result[0].score-0.1
      new_vote = Vote.new(voting_user: user.name, from_node: target_user,to_node: current_item, from_user: target_user.name,to_item:current_item.name )
      new_vote.save

      respond_to do |format|
        if @result[0].update(score: newscore)
          format.html { redirect_to current_item, notice: 'Trust was successfully updated.' }
          format.json { render :show, status: :created, location: @review }
        else
          format.html { render :edit }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  end

    

  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.permit(:name, :password, :password_confirmation, :created_at, :updated_at, :rec_item, :target_user,:current_item)
    end

