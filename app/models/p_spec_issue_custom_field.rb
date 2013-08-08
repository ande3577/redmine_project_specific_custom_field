#The hideously abbreviated name for this class is to solve the redmine 30 character limit on custom field type names
class PSpecIssueCustomField < CustomField
  unloadable
  
  include Redmine::I18n
  
  attr_accessor 'project'
  attr_accessor 'share_with_subprojects'
  
  validates_presence_of 'project'
  after_initialize 'initialize_project'
  after_initialize 'initialize_share_with_subproject'
  after_create 'create_projects'
  after_save 'update_share_with_subprojects'
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
  
  def visible_by?(project, user=User.current)
    super || (roles & user.roles_for_project(project)).present?
  end
  
  def initialize_project
    cfp = custom_field_project
    self.project = cfp.project unless cfp.nil?
  end
  
  def initialize_share_with_subproject
    cfp = custom_field_project
    self.share_with_subprojects = cfp.nil? ? true : cfp.share_with_subprojects
  end
  
  def create_projects
    self.project.project_specific_issue_custom_fields << self
    self.project.save
  end
  
  def update_share_with_subprojects
    cfp = custom_field_project
    cfp.share_with_subprojects = self.share_with_subprojects
    cfp.save
  end
  
  def self.customized_class
    Issue
  end
  
  def share_with_subprojects?
    self.share_with_subprojects
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
  
  def custom_field_project
    ProjectSpecificCustomFieldsProject.where(:custom_field_id => self.id).first unless self.id.nil?
  end
  
end
