class CreateProjectSpecificCustomFieldsProjects < ActiveRecord::Migration
  def change
    create_table :project_specific_custom_fields_projects do |t|
      t.integer :project_id
      t.integer :custom_field_id
    end
  end
end
