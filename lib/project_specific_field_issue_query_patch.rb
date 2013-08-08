module ProjectSpecificIssueQueryPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :initialize_available_filters, :project_specific
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
  
  def initialize_available_filters_with_project_specific
    print "\nadding project specific filters\n"
    initialize_available_filters_without_project_specific
    if project
      project.recursive_project_specific_issue_fields.each do |field|
        print "\nadding filter for #{field.name}\n"
        add_custom_field_filter(field) if field.visible
      end
    end
  end
  
end

IssueQuery.send(:include, ProjectSpecificIssueQueryPatch)