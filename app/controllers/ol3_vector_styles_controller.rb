class Ol3VectorStylesController < ApplicationController
  before_action :set_ol3_vector_style, only: [:show, :edit, :update, :destroy]

  # GET /ol3_vector_styles
  # GET /ol3_vector_styles.json
  def index
    @ol3_vector_styles = Ol3VectorStyle.all
  end

  # GET /ol3_vector_styles/1
  # GET /ol3_vector_styles/1.json
  def show
  end

  # GET /ol3_vector_styles/new
  def new
    @ol3_vector_style = Ol3VectorStyle.new
  end

  # GET /ol3_vector_styles/1/edit
  def edit
  end

  # POST /ol3_vector_styles
  # POST /ol3_vector_styles.json
  def create
    @ol3_vector_style = Ol3VectorStyle.new(ol3_vector_style_params)

    respond_to do |format|
      if @ol3_vector_style.save
        format.html { redirect_to @ol3_vector_style, notice: 'Ol3 vector style was successfully created.' }
        format.json { render :show, status: :created, location: @ol3_vector_style }
      else
        format.html { render :new }
        format.json { render json: @ol3_vector_style.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ol3_vector_styles/1
  # PATCH/PUT /ol3_vector_styles/1.json
  def update
    respond_to do |format|
      if @ol3_vector_style.update(ol3_vector_style_params)
        format.html { redirect_to @ol3_vector_style, notice: 'Ol3 vector style was successfully updated.' }
        format.json { render :show, status: :ok, location: @ol3_vector_style }
      else
        format.html { render :edit }
        format.json { render json: @ol3_vector_style.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ol3_vector_styles/1
  # DELETE /ol3_vector_styles/1.json
  def destroy
    @ol3_vector_style.destroy
    respond_to do |format|
      format.html { redirect_to ol3_vector_styles_url, notice: 'Ol3 vector style was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ol3_vector_style
      @ol3_vector_style = Ol3VectorStyle.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ol3_vector_style_params
      params.require(:ol3_vector_style).permit(:name, :alias, :stroke_width, :font_size, :stroke_color, :font_color, :fill_color, :style_type)
    end
end
