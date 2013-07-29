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
    available_custom_fields_without_project_specific + self.project.project_specific_issue_custom_fields.sorted.all
  end
  
end

Issue.send(:include, ProjectSpecificFieldIssuePatch)