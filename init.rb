require_dependency 'project_specific_field_project_patch'
require_dependency 'project_specific_field_issue_patch'
require_dependency 'project_specific_field_issue_query_patch'
require_dependency 'project_specific_field_projects_helper_patch'

Redmine::Plugin.register :redmine_project_specific_custom_field do
  permission :manage_project_custom_fields, :project_specific_fields => [ :index, :edit, :show, :update, :create, :new, :create_link ]
  permission :delete_project_custom_fields, :project_specific_fields => [ :destroy ]
    
  name 'Redmine Project Specific Field plugin'
  author 'David S Anderson'
  description 'Add the ability to create project specific custom fields'
  version '0.0.1'
  url 'http://www.github.com/ande3577/redmine_project_specific_field'
  author_url 'http://www.github.com/ande3577'
end
