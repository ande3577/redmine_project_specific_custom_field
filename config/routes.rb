# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get '/:id/project_specific_fields', to: 'project_specific_fields#index'
get '/:id/project_specific_fields/new', to: 'project_specific_fields#new'
post '/:id/project_specific_fields/create', to: 'project_specific_fields#create'
resources 'project_specific_fields', :only => [ :show, :edit, :update, :destroy]
  
