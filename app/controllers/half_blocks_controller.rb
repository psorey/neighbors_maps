class HalfBlocksController < ApplicationController
  # GET /half_blocks
  # GET /half_blocks.xml
  def index
    @half_blocks = HalfBlock.all
 
    # make a fixture file:
    #yf = File.open("half_blocks.yaml", "w")
    #@half_blocks.each do |hb|
    #  yf.puts hb.to_yaml
    #end



    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @half_blocks }
    end
  end

  # GET /half_blocks/1
  # GET /half_blocks/1.xml
  def show
    @half_block = HalfBlock.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @half_block }
    end
  end

  # GET /half_blocks/new
  # GET /half_blocks/new.xml
  def new
    @half_block = HalfBlock.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @half_block }
    end
  end

  # GET /half_blocks/1/edit
  def edit
    @half_block = HalfBlock.find(params[:id])
  end

  # POST /half_blocks
  # POST /half_blocks.xml
  def create
    @half_block = HalfBlock.new(params[:half_block])

    respond_to do |format|
      if @half_block.save
        format.html { redirect_to(@half_block, :notice => 'HalfBlock was successfully created.') }
        format.xml  { render :xml => @half_block, :status => :created, :location => @half_block }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @half_block.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /half_blocks/1
  # PUT /half_blocks/1.xml
  def update
    @half_block = HalfBlock.find(params[:id])

    respond_to do |format|
      if @half_block.update_attributes(params[:half_block])
        format.html { redirect_to(@half_block, :notice => 'HalfBlock was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @half_block.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /half_blocks/1
  # DELETE /half_blocks/1.xml
  def destroy
    @half_block = HalfBlock.find(params[:id])
    @half_block.destroy

    respond_to do |format|
      format.html { redirect_to(half_blocks_url) }
      format.xml  { head :ok }
    end
  end
end
