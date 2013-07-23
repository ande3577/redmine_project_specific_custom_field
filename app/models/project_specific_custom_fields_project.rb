class ProjectSpecificCustomFieldsProject < ActiveRecord::Base
  unloadable
  
  include Redmine::SafeAttributes
  
  belongs_to :project
  belongs_to :custom_field
end
