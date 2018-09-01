require File.expand_path('../../test_helper', __FILE__)

class IssueTest < ActiveSupport::TestCase
  fixtures :projects
  fixtures :issues 
  fixtures :trackers
  fixtures :users
  fixtures :enabled_modules
  
  def setup
    @project = Project.first
    @custom_field = PSpecIssueCustomField.new(:name => 'custom_field', :field_format => 'string', :project => @project, :searchable => true, :share_with_subprojects => true)
    assert @custom_field.save
  end
  
  def test_get_available_custom_fields
    add_tracker(1)
    assert  @project.issues.first.available_custom_fields.include?(@custom_field)
  end
  
  def test_get_available_custom_fields_for_own_tracker
    add_tracker(1)
    assert Issue.find(1).available_custom_fields.include?(@custom_field)
  end
  
  def test_get_available_custom_fields_for_own_tracker
    add_tracker(2)
    assert !Issue.find(1).available_custom_fields.include?(@custom_field)
  end
  
  def test_do_not_get_available_if_on_different_project
    add_tracker(1)
    assert !Issue.find(4).available_custom_fields.include?(@custom_field)
  end
  
  def test_inherit_from_parent
    add_tracker(1)
    assert Issue.find(6).available_custom_fields.include?(@custom_field)
  end
  
  def test_do_no_inherit_from_parent
    @custom_field.share_with_subprojects = false
    @custom_field.save
    add_tracker(1)
    assert !Issue.find(6).available_custom_fields.include?(@custom_field)
  end
  
  def test_search_results
    User.current = User.where(:admin => true).first
      
    issue = Issue.find(1)
    v = CustomValue.new(:custom_field => @custom_field, :customized => issue, :value => '1.234')
    assert v.save
    
    #proof that setup is correct
    r = Issue.search_results('%unable to print recipes%').first
    assert r.include?(issue)
    
    assert_equal @custom_field, PSpecIssueCustomField.where(:searchable => true).first
    
    r = Issue.search_results('%1.234%').first
    assert r.include?(issue)
  end
  
  def add_tracker(tracker_id)
    @custom_field.trackers << Tracker.find(tracker_id)
    @custom_field.save
    @custom_field.reload
  end
  
end
