class ProjectSpecificFieldsController < ApplicationController
  unloadable

  before_filter :find_field, :except => [:new, :create]
  before_filter :find_project, :only => [:new, :create]
  before_filter :authorize
  before_filter :build_field_from_params, :only => [:new, :create]
  
  helper 'custom_fields'

  def show
    respond_to do |format|
      format.html
    end
  end

  def new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    if @custom_field.save
      redirect_to_index
      return
    end
    render :action => :new
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    @custom_field.update_attributes(params[:p_spec_issue_custom_field])
    if @custom_field.save
      redirect_to_index
      return
    end
    render :action => :edit
  end

  def destroy
    @custom_field.destroy
    redirect_to_index    
  end
  
  private
  def find_field
    id = params[:id]
    @custom_field = PSpecIssueCustomField.where(:id => id).first unless id.nil?
    return render_404 if @custom_field.nil?
    @project = @custom_field.project
    return render_404 if @project.nil?
  end
  
  def find_project
    @project = Project.find(params[:id])
  end
  
  def authorize
    return deny_access if !User.current.allowed_to?({:controller => :project_specific_fields, :action => params[:action]}, @project, :global => false)
  end
  
  def build_field_from_params
    @custom_field = PSpecIssueCustomField.new(params[:p_spec_issue_custom_field])
    if params[:p_spec_issue_custom_field]
      @custom_field.share_with_subprojects = params[:p_spec_issue_custom_field][:share_with_subprojects] # force the update to be manual
    end
    @custom_field.project = @project
  end
  
  def redirect_to_index
    redirect_to :controller => :projects, :action => :settings, :id => @project.identifier, :tab => :custom_fields
  end
end
