
class UserFeaturesController < ApplicationController

  before_action :set_user_feature, only: [:show, :edit, :update, :destroy]

  def index
    @user_features = UserFeature.all
  end


  def show
  end


  def new
    @user_feature = UserFeature.new
  end


  def edit
  end


  def create
    @user_feature = UserFeature.new(user_feature_params)
    respond_to do |format|
      if @user_feature.save
        format.html { redirect_to @user_feature, notice: 'User feature was successfully created.' }
        format.json { render :show, status: :created, location: @user_feature }
      else
        format.html { render :new }
        format.json { render json: @user_feature.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @user_feature.update(user_feature_params)
        format.html { redirect_to @user_feature, notice: 'User feature was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_feature }
      else
        format.html { render :edit }
        format.json { render json: @user_feature.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @user_feature.destroy
    respond_to do |format|
      format.html { redirect_to user_features_url, notice: 'User feature was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private

    def set_user_feature
      @user_feature = UserFeature.find(params[:id])
    end


    def user_feature_params
      params.require(:user_feature).permit(:map_layer_id, :user_id, :name, :text, :number, :amount)
    end

end
