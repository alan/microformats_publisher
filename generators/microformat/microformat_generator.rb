#ENV["RAILS_ENV"] = "development"
#require(File.dirname(__FILE__) + "/../../../../../config/environment")
require 'microformats/generate'

class MicroformatGenerator < Rails::Generator::NamedBase::ModelGenerator

  attr_reader :models
  
  def initialize(runtime_args, runtime_options = {})
    super
    @models = [class_name] + Structure.get(class_name).all_models
  end
  

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name, "#{class_name}Test"
      unless options[:only_migration]
        # Model, test, and fixture directories.
        m.directory File.join('app/helpers', class_path)
        m.directory File.join('app/models', class_path)
        m.directory File.join('test/unit', class_path)
        m.directory File.join('test/fixtures', class_path)
    
        # Helper, Model class, unit test, and fixtures.
#        m.template 'helper.rb', File.join('app/helpers', class_path,
#          "#{file_name}_helper.rb")
        @models.each do |name|
          model_files_from_templates(m, Structure.get(name))
        end 
      end  
       
      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
            :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
          }, 
          :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end     
    end
  end

  private
  
    def model_files_from_templates(m, model)
      m.template 'model.rb', File.join('app/models',
        class_path, "#{model.singular_name}.rb"),
        :assigns => { :structure => model }
      m.template 'unit_test.rb', File.join('test/unit',
        class_path, "#{model.singular_name}_test.rb"),
        :assigns => { :structure => model }
      m.template 'fixtures.yml', File.join('test/fixtures',
        class_path, "#{model.table_name}.yml"),
        :assigns => { :structure => model }
    end

  protected
  
    def add_options!(opt)
      super
      opt.on('-m', '--only-migration', 
        "Only generate a migration file for this microformat") do |v| 
          options[:only_migration] = v 
      end  
    end
  

    # Override with your own usage banner.
    def banner
      "Usage: #{$0} #{spec.name} [options] uFormatName" 
    end
    
end
