class ProjectSpecificCustomFieldsProject < ActiveRecord::Base
  unloadable
  
  belongs_to :project
  belongs_to :custom_field
end
