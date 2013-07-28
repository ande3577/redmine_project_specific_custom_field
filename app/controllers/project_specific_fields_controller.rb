class ProjectSpecificFieldsController < ApplicationController
  unloadable

  before_filter :find_field, :except => [:index, :new, :create]
  before_filter :find_project, :only => [:index, :new, :create]
  before_filter :authorize

  def show
    respond_to do |format|
      format.html
      format.json
      format.xml
    end
  end

  def index
    @custom_fields = @project.project_specific_issue_custom_fields
    
    respond_to do |format|
      format.html
      format.json
      format.xml
    end
  end

  def new
    respond_to do |format|
      format.html
      format.json
      format.xml
    end
  end

  def create
    @custom_field = PSpecIssueCustomField.new(:project => @project)
    @custom_field.update_attributes(params[:project_specific_field])
    if @custom_field.save
      redirect_to :action => :index, :project_id => @project.id
      return
    end
    render :action => :new
  end

  def edit
    respond_to do |format|
      format.html
      format.json
      format.xml
    end
  end

  def update
    @custom_field.update_attributes(params[:project_specific_field])
    if @custom_field.save
      redirect_to :action => :index, :project_id => @project.id
      return
    end
    render :action => :edit
  end

  def destroy
    @custom_field.destroy
    
    redirect_to :action => :index, :project_id => @project.id
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
    project_id = params[:project_id]
    @project = Project.where(:id => project_id).first unless project_id.nil?
    return render_404 if @project.nil?
  end
  
  def authorize
    return deny_access if !User.current.allowed_to?({:controller => :project_specific_fields, :action => params[:action]}, @project, :global => false)
  end
end
