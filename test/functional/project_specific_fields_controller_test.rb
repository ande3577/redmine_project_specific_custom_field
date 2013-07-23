require File.expand_path('../../test_helper', __FILE__)

class ProjectSpecificFieldsControllerTest < ActionController::TestCase
  fixtures :projects 
  fixtures :custom_fields
  fixtures :users
  fixtures :roles
  fixtures :members
  fixtures :member_roles
  
  def setup
    @project = Project.where(:id => 1).first
    @custom_field = ProjectSpecificIssueField.new(:name => 'custom_field', :field_format => 'float', :project => @project)
    assert @custom_field.save
    
    @admin = User.where(:admin => true).first
    @request.session[:user_id] = @admin.id
  end
  
  def test_show
    get :show, :id => @custom_field.id
    assert_response 200
        
    assert_equal @project, assigns(:project)
    assert_equal @custom_field, assigns(:custom_field)
  end
  
  def test_show_invalid
    get :show, :id => 99
    assert_response 404
  end
  
  def test_edit
    get :edit, :id => @custom_field.id
    assert_response 200
    
    assert_equal @custom_field, assigns(:custom_field)
  end
  
  def test_index
    get :index, :project_id => @project.id
    assert_response 200
    
    assert_equal @project, assigns(:project)
    assert assigns(:custom_fields).include?(@custom_field)
  end
  
  def test_index_invalid_id
    get :index, :project_id => 99
    assert_response 404
  end
  
  def test_create
    assert_difference ['ProjectSpecificIssueField.count'] do
          post :create, :project_id => @project.id, :project_specific_field => { :name => 'new_custom_field', :field_format => 'float' }
    end
    
    assert_equal 'new_custom_field', assigns(:custom_field).name
    assert_equal 'float', assigns(:custom_field).field_format
    assert_equal assigns(:custom_field), ProjectSpecificIssueField.last
  end
  
  def test_create_no_name
    assert_difference ['ProjectSpecificIssueField.count'], 0 do
          post :create, :project_id => @project.id, :project_specific_field => { :name => '', :field_format => 'float' }
    end
    
    assert_response 200
    
    assert_not_nil assigns(:custom_field)
    assert_equal 'float', assigns(:custom_field).field_format
    assert_not_empty assigns(:custom_field).errors 
  end
  
  def test_update
    post :update, :id => @custom_field.id, :project_specific_field => { :name => 'rename_field', :field_format => 'string' }
    
    assert_redirected_to :action => :index, :project_id => @project.id
    
    @custom_field.reload
    
    assert_equal 'rename_field', @custom_field.name
    assert_equal 'float', @custom_field.field_format, "block changing format"
  end
  
  def test_destroy
    assert_difference ['ProjectSpecificIssueField.count'], -1 do
      delete :destroy, :id => @custom_field.id
    end
    
    assert_redirected_to :action => :index, :project_id => @project.id
  end
  
  def test_without_permission
    user = User.find(2)
    @request.session[:user_id] = user.id
      
    get :index, :project_id => @project.id
    assert_response 403
  end
  
  def test_with_permission
    user = User.find(2)
    @request.session[:user_id] = user.id
    Role.find(1).add_permission! :manage_project_custom_fields
      
    get :index, :project_id => @project.id
    assert_response 200
  end
  
end
