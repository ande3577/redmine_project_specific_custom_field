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
    def recursive_project_specific_issue_fields
      fields = []
      fields += self.parent.recursive_project_specific_issue_fields_from_parent unless self.parent.nil?
      fields + self.project_specific_issue_custom_fields.sorted.all
    end
    
    def recursive_project_specific_issue_fields_from_parent
      fields = []
      fields += self.parent.recursive_project_specific_issue_fields_from_parent unless self.parent.nil?
      fields += self.project_specific_issue_custom_fields.sorted.all.select  { |f| f.share_with_subprojects? }
      fields
    end
  end
  
  def destroy_project_specific_custom_fields
    project_specific_issue_custom_fields.each do |f|
      f.destroy()
    end
  end
  
end

Project.send(:include, ProjectSpecificFieldProjectPatch)