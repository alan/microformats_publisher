module Microformats

# UfEnumerable adds the Enumerable module into the class methods for the
# Microformats::Structures class and defines the each method to enumerate
# over the structures within the Microformats::Structures namespace.

  module UfEnumerable

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      include Enumerable
      def each
        this_name_space = Regexp.new("^#{self.name}")
        constants.each do |const|
          constant = const_get(const)
          yield constant if constant.to_s =~ this_name_space
        end
      end
      
    end # ClassMethods
    
  end # UfEnumerable
  
end # Microformats