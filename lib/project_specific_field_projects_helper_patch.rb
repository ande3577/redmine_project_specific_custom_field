module ProjectSpecificFieldProjectsHelperPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :project_settings_tabs, :project_specific_tab
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
  
  def project_settings_tabs_with_project_specific_tab
    project_settings_tabs_without_project_specific_tab << {:name => 'custom_fields', :action => :manage_project_activities, :partial => 'projects/settings/custom_fields', :label => :label_custom_field_plural}
  end
  
end

ProjectsHelper.send(:include, ProjectSpecificFieldProjectsHelperPatch)