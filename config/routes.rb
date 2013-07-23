# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources 'projects', :only => [] do
  resources 'project_specific_fields', :only => [:index, :new, :create]
end

resources 'project_specific_fields', :only => [ :show, :edit, :update, :destroy]
  
