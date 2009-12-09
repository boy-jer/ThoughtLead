class DiscussionsController < ApplicationController
  before_filter :login_required, :except => [ :index, :uncategorized, :show ]
  before_filter :load_objects
  before_filter :load_accessible_themes, :only => [:new, :create, :edit, :update]
  before_filter :community_is_active
  before_filter :set_section_title
  

  def index
    @discussions = filter_and_paginate_discussions(@theme.nil? ? current_community.discussions.accessible_to(current_user).by_age : @theme.discussions.accessible_to(current_user).by_age)
    unless @theme.nil?
      set_headline :subsection => @theme.name
    end
  end

  def uncategorized
    @discussions = filter_and_paginate_discussions(current_community.discussions.uncategorized)
  end

  def new
    @discussion = Discussion.new
    set_headline :content => "Start a New Discussion"
  end

  def create
    @discussion = current_community.discussions.build(params[:discussion])
    @discussion.user = current_user

    return render(:action => :new) unless @discussion.save

    User.find_all_by_community_and_send_email_notifications(current_community, true).each do |member|
      EmailSubscriptionMailer.deliver_discussion_created(member, @discussion) if member.has_access_to(@discussion)
    end

    flash[:notice] = "Successfully created"
    redirect_to @discussion
  end

  def edit
    unless current_user == @discussion.user || logged_in_as_owner?
      redirect_to @discussion
    end
    set_headline :content => "Edit Discussion - #{@discussion.title}"
    
  end

  def update
    return render(:action => :edit) unless @discussion.update_attributes(params[:discussion])

    flash[:notice] = "Successfully saved"
    redirect_to @discussion
  end

  def show
    @discussion = current_community.discussions.find(params[:id])
    @responses = @discussion.responses
    @responses = @responses.paginate :page => params[:page], :per_page => 20
    @email_subscription = @discussion.email_subscriptions.find_by_subscriber_id(current_user.id) if current_user
    set_headline :content => @discussion.title
  end

  def destroy
    @discussion = current_community.discussions.find(params[:id])
    flash[:notice] = "Successfully deleted the discussion post."
    @discussion.destroy
    redirect_to discussions_url
  end

  private
  
  def set_section_title
    set_headline :section => 'Discussions'
  end

  def load_accessible_themes
    @accessible_themes = current_community.themes.select { |theme| current_user.has_access_to(theme) }
  end

  def filter_and_paginate_discussions(discussions)
    # discussions = discussions.find_all { |discussion| discussion.is_visible_to(current_user) }

    discussions = discussions.paginate :page => params[:page], :per_page => 20
  end

  def get_access_controlled_object
    return current_community.discussions.find(params[:id]) if params[:id]
    return current_community.themes.find(params[:theme_id]) if params[:theme_id]
    return current_community.themes.find(params[:discussion][:theme_id]) if params[:discussion] && !params[:discussion][:theme_id].blank?
  end

  def load_objects
    if params[:id]
      @discussion = current_community.discussions.find(params[:id])
      @theme = @discussion.theme
    elsif params[:theme_id]
      @theme = current_community.themes.find(params[:theme_id])
    end
  end
end
