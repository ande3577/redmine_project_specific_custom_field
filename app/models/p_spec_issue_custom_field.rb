#The hideously abbreviated name for this class is to solve the redmine 30 character limit on custom field type names
class PSpecIssueCustomField < CustomField
  unloadable
  
  include Redmine::I18n
  
  attr_accessor 'project'
  
  validates_presence_of 'project'
  after_initialize 'initialize_project'
  after_create 'create_projects'
  has_one :project_specific_custom_fields_project, :dependent => :destroy, :foreign_key => 'custom_field_id'
  has_and_belongs_to_many :trackers, :join_table => "#{table_name_prefix}custom_fields_trackers#{table_name_suffix}", :foreign_key => "custom_field_id"

  validate do
    #if we get an error that the name has already been taken, and it is the only name error,
    # delete it if it is unique for the project
    errors.each do |attribute, error|
      if attribute == :name and errors.get(attribute).size == 1 and error == I18n.t(:taken, scope: [:activerecord, :errors, :messages]) and name_unique_for_project?()
        errors.delete(attribute)
      end
    end
  end
  
  def type_name
    :label_project_specific_issue_custom_field_plural
  end
  
  def initialize_project
    cfp = ProjectSpecificCustomFieldsProject.where(:custom_field_id => self.id).first unless self.id.nil?
    self.project = cfp.project unless cfp.nil?
  end
  
  def create_projects
    self.project.project_specific_issue_custom_fields << self
    self.project.save
  end
  
  def self.customized_class
    Issue
  end
  
  private
  def name_unique_for_project?()
    for f in IssueCustomField.all + self.project.project_specific_issue_custom_fields
      if (self.name == f.name) and (self.field_format == f.field_format) and (f != self)
        return false
      end
    end
    true
  end
  
end
