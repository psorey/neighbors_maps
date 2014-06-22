class AdministratorsController < ApplicationController

  # !!! require_role "admin"



  def index
    @administrators = Administrator.all
  end



  def show
    @administrator = Administrator.find(params[:id])
  end



  def new
    @administrator = Administrator.new
  end



  def edit
    @administrator = Administrator.find(params[:id])
  end



  def create
    @administrator = Administrator.new(params[:administrator])
    if @administrator.save
      redirect_to(@administrator, :notice => 'Administrator was successfully created.')
    else
      render :action => "new"
    end
  end



  def update
    @administrator = Administrator.find(params[:id])
    if @administrator.update_attributes(params[:administrator])
      redirect_to(@administrator, :notice => 'Administrator was successfully updated.') 
    else
      render "edit"
    end
  end



  def destroy
    @administrator = Administrator.find(params[:id])
    @administrator.destroy
    redirect_to(administrators_url)
  end


end
