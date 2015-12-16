class VectorFeaturesController < ApplicationController
  before_action :set_vector_feature, only: [:show, :edit, :update, :destroy]

  # GET /vector_features
  # GET /vector_features.json
  def index
    @vector_features = VectorFeature.all
  end

  # GET /vector_features/1
  # GET /vector_features/1.json
  def show
  end

  # GET /vector_features/new
  def new
    @vector_feature = VectorFeature.new
  end

  # GET /vector_features/1/edit
  def edit
  end

  # POST /vector_features
  # POST /vector_features.json
  def create
    @vector_feature = VectorFeature.new(vector_feature_params)

    respond_to do |format|
      if @vector_feature.save
        format.html { redirect_to @vector_feature, notice: 'Vector feature was successfully created.' }
        format.json { render :show, status: :created, location: @vector_feature }
      else
        format.html { render :new }
        format.json { render json: @vector_feature.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vector_features/1
  # PATCH/PUT /vector_features/1.json
  def update
    respond_to do |format|
      if @vector_feature.update(vector_feature_params)
        format.html { redirect_to @vector_feature, notice: 'Vector feature was successfully updated.' }
        format.json { render :show, status: :ok, location: @vector_feature }
      else
        format.html { render :edit }
        format.json { render json: @vector_feature.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vector_features/1
  # DELETE /vector_features/1.json
  def destroy
    @vector_feature.destroy
    respond_to do |format|
      format.html { redirect_to vector_features_url, notice: 'Vector feature was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vector_feature
      @vector_feature = VectorFeature.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vector_feature_params
      params.require(:vector_feature).permit(:name, :text, :vector_type, :amount, :number, :guid)
    end
end
