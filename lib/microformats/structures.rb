module Microformats

  module ArgsToAttributes
    def args_to_attributes(args)
      args.inject({}.extend(Appenders::Hashs)) do |hash, arg|
        hash << ( arg.kind_of?(Hash) ? arg : { arg => {} } )
      end
    end
  end

# The Microformats::Structures calls provides class methods to access the
# structures that are constructed from the structures directory.

  class Structure < BlankSlate
  
    include ArgsToAttributes
    include Defaults
    include Inflect
    include Appenders

    @@structures = {}
    @@db_attributes = %w(binary boolean date datetime decimal float integer string text time timestamp)
    @@accessors = [ :identity, :singular_name, :plural_name, :table_name, :class_name ]
    @@array_accessors = [ :has_one, :has_many, :belongs_to, :serialize, :sub_formats ]
    @@hash_accessors = [ :validations, :attributes ]
    @@array_validations = [ :presence, :uniqueness, :confirmation, :numericality ]
    @@hash_validations = [ :exclusion, :format, :inclusion, :length ]

    cattr_reader :structures
    attr_reader *@@accessors
    attr_reader *@@array_accessors
    attr_reader *@@hash_accessors

    # get the structure classess or load them if they are missing.
    def self.get(name, options = {})
      names = inflect_names(name)
      structure = @@structures[names[:camel]] unless options[:reload]
      structure = locate(names[:under]) unless structure.instance_of? self
      return @@structures[names[:camel]] = structure if structure.instance_of? self
      raise NameError, "Structure not found: #{name}", caller
    end
    
    # return all the structures
    def self.each
      if block_given?
        @@structures.each { |name, structure| yield name, structure }
      else
        raise LocalJumpError, "no block given", caller
      end
    end

    # methods to iterate over the microformat and model definitions
    def each_sub_structure
      return_formats = []
      sub_formats.each do |sub_name|
        sub_format = self.class.get(sub_name)
        return_formats << sub_name
        return_formats = return_formats | sub_format.each_sub_structure
      end
      if block_given?
        return_formats.each { |format| yield format }
      else
        return_formats
      end
    end

    def all_models
      return_models = []
      models.each do |sub_name|
        sub_model = self.class.get(sub_name)
        return_models << sub_name
        return_models = return_models | sub_model.all_models
      end
      if block_given?
        return_models.each { |model| yield model }
      else
        return_models
      end
    end

    def models
      @has_one + @has_many
    end
    
    private

    def define(name, &block)
      assign_names(name) if name
      yield if block_given?
    end

    def has(quantal, *args, &block)
      if quantal.kind_of?(Array)
       quantal, attributes =  *quantal
      else
       quantal, attributes = quantal.to_sym, args_to_attributes(args)
      end
      if block
        method_calls = {}.extend(Appenders::Hashs)
        (class << block; self; end).class_eval do
          instance_methods.each do |m|
            undef_method(m) unless ( m =~ /^__/ || ["instance_eval"].include?(m) )
          end
          include ArgsToAttributes
          define_method(:method_missing) do |m, *args|
            method_calls << { m.to_sym => args_to_attributes(args) }
          end
        end
        attributes = block.instance_eval(&block)
      end
      parse quantal, attributes
    end

    [:one, :many].each do |methd|
      class_eval <<-EOF
        def #{methd}(*args)
          [ :#{methd.to_sym}, args_to_attributes(args) ]
        end
      EOF
    end

    def identifier(identity)
      @identity = identity
    end

    def parse(quantal, attributes)
      relationship = "has_#{quantal}"
      attributes.each do |attribute, options|
        type = (options.delete(:type) || :string).to_sym
        if type == :uformat
          add_sub_structure attribute, relationship
          @sub_formats << attribute
        elsif type == :model
          add_sub_structure attribute, relationship
        else
          if @@pseudo_types[type]
            options.merge!( @@pseudo_types[type] ) { |key, old, new| old }
          else
            options.merge!( { :type => type } )
          end
          @attributes[attribute] = extract_validations(attribute, options)
          @serialize << attribute if quantal == :many
        end
      end
    end

    # take the validations out of the options hash, populate the validations hash and 
    # return a clean options hash.
    def extract_validations(attribute, options)
      if options[:size]
        size = options.delete(:size)
        case size.class.name
        when 'Fixnum'
          options[:limit] = size
          @validations[:length] << { attribute => { :maximum => size }}
        when 'Range'
          options[:limit] = size.end
          @validations[:length] << { attribute => { :in => size }}
        end
      end  
      @validations[:format] << { attribute => options.delete(:format) } if options[:format]
      @validations[:inclusion] << { attribute => options.delete(:select_from) } if options[:select_from]
      @validations[:exclusion] << { attribute => options.delete(:excludes) } if options[:exlcudes]
      @validations[:numericality] << attribute if [:fixnum, :float].include?(options[:type])
      @validations[:confirmation] << attribute if options.delete(:confirmation)   
      @validations[:presence] << attribute if options.has_key?(:null) && options[:null] == false
      @validations[:uniqueness] << attribute if options.delete(:unique)
      options
    end
    
    def add_sub_structure(name, relationship)
      sub_struct_name = inflect_names(name)[:under]
      sub_struct = self.class.get(sub_struct_name)  
      sub_struct.belongs_to << singular_name
      send(relationship) << sub_struct.singular_name
    end
    
    def initialize(name)
      @@array_accessors.each do |accessor|
        instance_variable_set("@#{accessor}", [].extend(Appenders::Arrays))
      end
      @@hash_accessors.each do |accessor|
        instance_variable_set("@#{accessor}", {}.extend(Appenders::Hashs))
      end
      @@array_validations.each do |validation|
        @validations[validation] = [].extend(Appenders::Arrays)
      end
      @@hash_validations.each do |validation|
        @validations[validation] = {}.extend(Appenders::Hashs)
      end
      assign_names(name)
    end

    def assign_names(name)
      names = inflect_names(name)
      @class_name, @plural_name, @singular_name = names[:camel], names[:plural], names[:under]
      @table_name = ActiveRecord::Base.pluralize_table_names ? names[:plural] : names[:under]
    end

    def self.locate(name)
      paths = ENV['STRUCTURE_PATH'].split(";")
      paths.each do |path|
        file_name = File.join(File.expand_path(path),"#{name}.rb" )
        if File.file?(file_name)
          structure = new(name)
          structure.instance_eval(File.read(file_name))
          return structure
        end
      end
    end

  end # Microformats::Structure
  
end
 
