require File.expand_path('../../test_helper', __FILE__)

class IssueQueryTest < ActiveSupport::TestCase
  fixtures :projects
  fixtures :queries 
  
  def setup
    @project = Project.first
    @custom_field = PSpecIssueCustomField.new(:name => 'custom_field', :field_format => 'float', :project => @project)
    
    @query = IssueQuery.first
  end
  
  def test_intialize_available_filters
    initial_size = IssueQuery.first.available_filters.count
    assert @custom_field.save
    @query.reload
    final_size = IssueQuery.first.available_filters.count
    assert_not_equal initial_size, final_size
  end
  
  def test_available_columns
    initial_size = IssueQuery.first.available_columns.count
    assert @custom_field.save
    @query.reload
    final_size = IssueQuery.first.available_columns.count
    assert_not_equal initial_size, final_size
  end
  
end
