class AccessClassesController < ApplicationController
  helper AdminHelper
  before_filter :owner_login_required

  def index
    @community = current_community
    @access_class = AccessClass.new
  end

  def create
    @community = current_community
    @access_class = current_community.access_classes.build(:name => params[:access_class][:name])

    return render(:action => :index) unless @access_class.update_attributes(params[:access_class])
    flash[:notice] = "Access Level \"#{@access_class.name}\" created."
    redirect_to access_classes_url
  end

  def update
    @access_class = current_community.access_classes.find(params[:id])

    return render(:action => :edit) unless @access_class.update_attributes(params[:access_class])

    flash[:notice] = "Successfully saved \"#{@access_class.name}\""
    redirect_to access_classes_url
  end

  def edit
    @community = current_community
    @access_class = current_community.access_classes.find(params[:id])
  end
  
  def toggle
    @community = current_community
    @access_class = current_community.access_classes.find(params[:id])
    if @access_class.toggle!(:activated)
      aktion = @access_class.activated? ? "enabled" : "disabled"
      flash[:notice] = "Successfully #{aktion} #{@access_class.name} access level"
    end
    redirect_to :action => 'index'
  end
end
