class ProjectSpecificCustomFieldsProject < ActiveRecord::Base
  unloadable
  
  include Redmine::SafeAttributes
  
  belongs_to :project
  belongs_to :custom_field
  
  safe_attributes :share_with_subprojects
end
