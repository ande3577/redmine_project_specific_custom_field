module ProjectSpecificFieldIssuePatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      def available_custom_fields
        fields = CustomField.where("type = '#{self.class.name}CustomField'").sorted.all
        CustomField.where("type='PSpec#{self.class.name}CustomField'").each do |f|
          if f.project == self.project
            fields << f
          end
        end
        fields
      end
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
  
end

Issue.send(:include, ProjectSpecificFieldIssuePatch)