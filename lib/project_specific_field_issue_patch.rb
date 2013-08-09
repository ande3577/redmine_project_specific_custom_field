module ProjectSpecificFieldIssuePatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :available_custom_fields, :project_specific
      class << self
        alias_method_chain :search, :project_specific
      end
    end
  end
  
  module ClassMethods
    def search_with_project_specific(tokens, projects=nil, options={})
      resultsList = search_without_project_specific(tokens, projects, options)
      results  = resultsList[0]
      results_count  = resultsList[1]
      
      user = User.current
      tokens = [] << tokens unless tokens.is_a?(Array)
      projects = [] << projects unless projects.nil? || projects.is_a?(Array)
    
      limit_options = {}
      limit_options[:limit] = options[:limit] if options[:limit]
      
      token_clauses = []
      if !options[:titles_only] && searchable_options[:search_custom_fields]
        PSpecIssueCustomField.where(:searchable => true).each do |field|
          sql = "#{table_name}.id IN (SELECT customized_id FROM #{CustomValue.table_name}" +
            " WHERE customized_type='#{self.name}' AND customized_id=#{table_name}.id AND LOWER(value) LIKE ?" +
            " AND #{CustomValue.table_name}.custom_field_id = #{field.id})"
          if PSpecIssueCustomField.method_defined?(:visibility_by_project_condition)
              sql += " AND #{field.visibility_by_project_condition(searchable_options[:project_key], user)}"
          end
          token_clauses << sql
        end
      end
      
      unless token_clauses.empty?
        sql = (['(' + token_clauses.join(' OR ') + ')'] * tokens.size).join(options[:all_words] ? ' AND ' : ' OR ')
        tokens_conditions = [sql, * (tokens.collect {|w| "%#{w.downcase}%"} * token_clauses.size).sort]
        scope = self.scoped
        project_conditions = []
        if searchable_options.has_key?(:permission)
          project_conditions << Project.allowed_to_condition(user, searchable_options[:permission] || :view_project)
        elsif respond_to?(:visible)
          scope = scope.visible(user)
        else
          ActiveSupport::Deprecation.warn "acts_as_searchable with implicit :permission option is deprecated. Add a visible scope to the #{self.name} model or use explicit :permission option."
          project_conditions << Project.allowed_to_condition(user, "view_#{self.name.underscore.pluralize}".to_sym)
        end
        # TODO: use visible scope options instead
        project_conditions << "#{searchable_options[:project_key]} IN (#{projects.collect(&:id).join(',')})" unless projects.nil?
        project_conditions = project_conditions.empty? ? nil : project_conditions.join(' AND ')
        
        scope = scope.
          includes(searchable_options[:include]).
          order("#{searchable_options[:order_column]} " + (options[:before] ? 'DESC' : 'ASC')).
          where(project_conditions).
          where(tokens_conditions)
        
        if options[:limit].nil? or results_count < options[:limit]  
          scope_with_limit = scope.limit(options[:limit].nil? ? nil : (options[:limit] - results_count))
          if options[:offset]
            scope_with_limit = scope_with_limit.where("#{searchable_options[:date_column]} #{options[:before] ? '<' : '>'} ?", options[:offset])
          end
          results += scope_with_limit.all
        end
        
        results_count += scope.count
      end
      
      [results, results_count]
    end
  end
  
  module InstanceMethods
  end
  
  def available_custom_fields_with_project_specific
    fields = available_custom_fields_without_project_specific
    fields += self.project.recursive_project_specific_issue_fields.select { |f| f.trackers.include?(self.tracker) } if (self.project and self.tracker)
    fields
  end
  
end

Issue.send(:include, ProjectSpecificFieldIssuePatch)