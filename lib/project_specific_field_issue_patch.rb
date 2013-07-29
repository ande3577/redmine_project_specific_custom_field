module ProjectSpecificFieldIssuePatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :available_custom_fields, :project_specific
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
  
  def available_custom_fields_with_project_specific
    fields = available_custom_fields_without_project_specific
    fields += self.project.recursive_project_specific_issue_fields
    fields
  end
  
end

Issue.send(:include, ProjectSpecificFieldIssuePatch)