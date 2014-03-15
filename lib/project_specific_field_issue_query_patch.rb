module ProjectSpecificIssueQueryPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :initialize_available_filters, :project_specific
      alias_method_chain :available_columns, :project_specific
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
  
  def initialize_available_filters_with_project_specific
    initialize_available_filters_without_project_specific
    if project
      begin
        project.recursive_project_specific_issue_fields.each do |field|
          add_custom_field_filter(field) if field.visible
        end
      rescue
        # provide support for redmine 2.3
        add_custom_fields_filters(project.recursive_project_specific_issue_fields.select { |f| f.visible })
      end
    end
  end
  
  def available_columns_with_project_specific
    return @available_columns if @available_columns
    @available_columns = available_columns_without_project_specific
    if project
      project.recursive_project_specific_issue_fields.each do |field|
        @available_columns << QueryCustomFieldColumn.new(field) if field.visible
      end
    end
    print @available_columns.size
    
    @available_columns
  end
  
end

IssueQuery.send(:include, ProjectSpecificIssueQueryPatch)