require File.expand_path('../../test_helper', __FILE__)

class IssueTest < ActiveSupport::TestCase
  fixtures :projects
  fixtures :issues 
  
  def setup
    @project = Project.first
    @custom_field = PSpecIssueCustomField.new(:name => 'custom_field', :field_format => 'float', :project => @project)
    assert @custom_field.save
  end
  
  def test_get_available_custom_fields
    assert  @project.issues.first.available_custom_fields.include?(@custom_field)
  end
  
  def test_do_not_get_available_if_on_different_project
    assert !Issue.find(4).available_custom_fields.include?(@custom_field)
  end
  
  def test_inherit_from_parent
    assert Issue.find(6).available_custom_fields.include?(@custom_field)
  end
  
end
