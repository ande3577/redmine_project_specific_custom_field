class ProjectSpecificFieldsController < ApplicationController
  unloadable

  before_filter :find_field, :except => [:index, :new, :create]
  before_filter :find_project, :only => [:index, :new, :create]
  before_filter :authorize
  before_filter :build_field_from_params, :only => [:new, :create]
  
  helper 'custom_fields'

  def show
    respond_to do |format|
      format.html
    end
  end

  def index
    @custom_fields = @project.project_specific_issue_custom_fields
    
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
      redirect_to :action => :index, :id => @project.identifier
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
      redirect_to :action => :index, :id => @project.identifier
      return
    end
    render :action => :edit
  end

  def destroy
    @custom_field.destroy
    
    redirect_to :action => :index, :id => @project.identifier
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
    project_id = params[:id]
    @project = Project.where(:identifier => project_id).first unless project_id.nil?
    return render_404 if @project.nil?
  end
  
  def authorize
    return deny_access if !User.current.allowed_to?({:controller => :project_specific_fields, :action => params[:action]}, @project, :global => false)
  end
  
  def build_field_from_params
    @custom_field = PSpecIssueCustomField.new(params[:p_spec_issue_custom_field])
    @custom_field.project = @project
  end
end
