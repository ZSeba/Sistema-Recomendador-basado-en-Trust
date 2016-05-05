class TrustsController < ApplicationController
  before_action :set_trust, only: [:show, :edit, :update, :destroy]

  # GET /trusts
  # GET /trusts.json
  def index
    @trusts = Trust.all
  end

  # GET /trusts/1
  # GET /trusts/1.json
  def show
  end

  # GET /trusts/new
  def new
    @trust = Trust.new
  end

  # GET /trusts/1/edit
  def edit
  end

  # POST /trusts
  # POST /trusts.json
  def create
    @trust = Trust.new(trust_params)

    respond_to do |format|
      if @trust.save
        format.html { redirect_to @trust, notice: 'Trust was successfully created.' }
        format.json { render :show, status: :created, location: @trust }
      else
        format.html { render :new }
        format.json { render json: @trust.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trusts/1
  # PATCH/PUT /trusts/1.json
  def update
    respond_to do |format|
      if @trust.update(trust_params)
        format.html { redirect_to @trust, notice: 'Trust was successfully updated.' }
        format.json { render :show, status: :ok, location: @trust }
      else
        format.html { render :edit }
        format.json { render json: @trust.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trusts/1
  # DELETE /trusts/1.json
  def destroy
    @trust.destroy
    respond_to do |format|
      format.html { redirect_to trusts_url, notice: 'Trust was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trust
      @trust = Trust.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trust_params
      params.require(:trust).permit(:score)
    end
end
