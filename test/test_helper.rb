ENV["RAILS_ENV"] = "test"
require(File.dirname(__FILE__) + "/../../../../config/environment")

structure_path = File.expand_path( 'test/structures', ENV['MICROFORMATS_ROOT'] )
ENV['STRUCTURE_PATH'] = [ structure_path, ENV['STRUCTURE_PATH'] ].join( ';' )


require 'microformats/test_help'

class Test::Unit::TestCase


  def self.structure_fixtures(*names)
    names.flatten.collect! { |name| name.to_s }.each do |name|
      fixture_file = File.expand_path( "test/fixtures/#{name}.yml", ENV['MICROFORMATS_ROOT'] )
      instance_variable_set("@#{name}", load_fixture( fixture_file ) )
    end
  end
  
  def self.load_fixture(yaml_file_path)

    begin
      YAML::load(erb_render(IO.read(yaml_file_path)))
    rescue Exception => boom
      raise "a YAML error occured parsing #{yaml_file_path}. Please note that YAML must be consistently indented using spaces. Tabs are not allowed. Please have a look at http://www.yaml.org/faq.html\nThe exact error was:\n  #{boom.class}: #{boom}"
    end
      
  end
  
  def self.erb_render(fixture_content)
    ERB.new(fixture_content).result
  end

end  # Test::Unit::TestCase