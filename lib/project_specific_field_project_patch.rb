module ProjectSpecificFieldProjectPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      has_and_belongs_to_many :project_specific_issue_custom_fields,
                              :class_name => 'PSpecIssueCustomField',
                              :order => "#{CustomField.table_name}.position",
                              :join_table => "#{table_name_prefix}project_specific_custom_fields_projects#{table_name_suffix}",
                              :association_foreign_key => 'custom_field_id'
                              
      before_destroy :destroy_project_specific_custom_fields
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
  
  def destroy_project_specific_custom_fields
    project_specific_issue_custom_fields.each do |f|
      f.destroy()
    end
  end
  
end

Project.send(:include, ProjectSpecificFieldProjectPatch)