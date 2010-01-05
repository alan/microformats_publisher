module Microformats

  module Inflect

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
    
      def inflect_names(name)
        camel = name.to_s.split('::').pop.singularize.camelize
        under  = camel.underscore
        plural = under.pluralize
        { :camel => camel, :plural => plural, :under => under }
      end
      
    end
    
    include ClassMethods

  end
  
end