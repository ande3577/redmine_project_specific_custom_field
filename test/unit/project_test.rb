require File.expand_path('../../test_helper', __FILE__)

class ProjectTest < ActiveSupport::TestCase
  fixtures :projects 
  
  def setup
    @project = Project.first
    @custom_field = ProjectSpecificIssueField.new(:name => 'custom_field', :field_format => 'float', :project => @project)
    assert @custom_field.save
  end
  
  def test_get_project_custom_field
    assert @project.project_specific_issue_custom_fields.visible.include?(@custom_field)
  end
  
  def test_destoy_project
    assert_difference ['ProjectSpecificIssueField.count', 'ProjectSpecificCustomFieldsProject.count'], -1 do
      @project.destroy()
    end
  end
  
end
