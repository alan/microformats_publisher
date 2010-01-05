require 'prettyprint'
require 'pp'

module Microformats

  class Emmitter < PrettyPrint
  
    def linebreak
      self.breakable(' ', @maxwidth)
    end

    def self.start_block(starting, options = {}, &block)
      options[:width] ||= 79
      output = ''
      q = new(output, options[:width])
      q.add_block(starting, options, &block)
      q.flush
      output
    end
    
    def add_block(starting, options = {}, &block)
      options[:ending] ||= 'end'
      options[:indent] ||= 0
      options[:break_before] = true unless options.has_key?(:break_before)
      nest(options[:indent]) do
        linebreak if options[:break_before]
        group(0, starting, options[:ending]) do 
          if block_given?
            yield self
          end
          linebreak
        end
      end
    end  

    def add_text(content, options = {} )
      continuation = options.has_key?(:continuation) ? options[:continuation] : ','
      text continuation if continuation
      breakable
      text content
    end

    def add_parameter(options, value, key = value)
      add_text ":#{key} => #{options[value]}" if options.has_key?(value)
    end

    def append(value, options = {})
      if value.kind_of? Hash
      end
    end
  end # Emmitter
  
  class Generate
  
    def self.migration(name, models, options = {:indent => 2})    
      Emmitter.start_block "class #{name} < ActiveRecord::Migration", :break_before => false do |q|
        q.linebreak
        create_tables q, models, options
        q.linebreak
        drop_tables q, models, options
        q.linebreak
      end
    end
      
    def self.drop_tables(q, models, options = {:indent => 2})
      q.add_block "def self.down", options do |q|
        q.nest(options[:indent]) do
          traverse models do |model|
            q.add_text "drop_table :#{model.table_name}",  :continuation => false 
          end 
        end	
      end
    end
  
    # create the migration table header and then call each generate_column on
    # each column within the table
    def self.create_tables(q, models, options = {:indent => 2})
      q.add_block "def self.up", options do
        traverse models do |model|
          q.linebreak
          q.add_block "create_table :#{model.table_name}, :force => true do |t|", options do 
            model.attributes.each do |name, parameters| 
              q.nest(options[:indent]) { add_column q, name, parameters }  
            end 
          end
        end 
        q.linebreak
      end
    end

    def self.traverse(names, &block)
      names = [names] unless names.kind_of? Array
      names.each { |name| yield(Structure.get(name)) }  
    end
    
    # render a migration column
    def self.add_column(q, name, parameters)
      q.linebreak
      q.group do
        q.text "t.column :#{name}"
        q.add_text ":#{parameters[:type]}"
        case  parameters[:type].to_sym
        when :string
          q.add_parameter parameters, :limit
        when :decimal
          q.add_parameter parameters, :precision
          q.add_parameter parameters, :scale
        end
        q.add_parameter parameters, :null
        q.add_parameter parameters, :default
      end
    end

    def self.model_for( model, options = {:indent => 2})    
      Emmitter.start_block "class #{model.class_name} < ActiveRecord::Base", :break_before => false do |q|
        q.linebreak
        q.nest(options[:indent]) do				
         # q.group do
            %w(belongs_to has_many has_one serialize).each do |definition|
              add_definition q, model, definition
            end
    #      end
          q.group do
            model.validations.each do |key, value| 
              puts "creating validation #{key} for model #{model.table_name} with #{value.class} values: #{value.inspect}"
              add_validation( q, key, value ) unless value.empty?
            end
          end  
        end
        q.linebreak
      end
    end 

    def self.add_validation(q, key, value)
      if value.kind_of? Array
        q.linebreak
        q.group do
          q.text "validates_#{key}_of :#{value.shift}"
          value.each do | attribute |
            q.add_text ":#{attribute}"
          end
        end
      end 
      if value.kind_of? Hash
        value.each do |k, v|
          q.linebreak
          q.group do
            q.text "validates_#{key}_of :#{k}"
            send("parse_#{key}_validation", q, v)
          end
        end  
      end        
    end
    
    def self.add_definition(q, model, definition)
      values = model.send(definition)
      unless values.empty?
        q.linebreak			
        q.group do 
          values.each do |value|
            q.text "#{definition} :#{value}"
            q.linebreak
          end
        end	
      end  
    end
    
    def self.parse_length_validation(q, attributes)
      attributes.each do |attribute, value|
        q.add_parameter attributes, attribute
      end
    end
    
    def self.parse_inclusion_validation(q, attributes)
      values = attributes.kind_of?(Hash) ? attributes.keys.sort : attributes
      q.add_text ":in => " + values.pretty_inspect
    end
    
    def self.parse_exclusion_validation(q, attributes)
      values = attributes.kind_of?(Hash) ? attributes.keys : attributes
      q.add_text ":in => " + values.pretty_inspect
    end
    
    def self.parse_format_validation(q, attributes)
      q.add_text ":with => #{attributes}"
    end
		
  end # Generate

end # Microformats