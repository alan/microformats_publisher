structure_path = File.expand_path( 'test/structures', ENV['MICROFORMATS_ROOT'] )
ENV['STRUCTURE_PATH'] = [ structure_path, ENV['STRUCTURE_PATH'] ].join( ';' )

require 'erb'
require 'yaml'

module Microformats

  class Structure
  
    # Writes content of all the currently loaded structures to
    # test/fixtures/structures.yml, or the specified file.
    def self.dump_all_to_file(file = nil)
      fixture_path = File.expand_path( 'test/fixtures', ENV['MICROFORMATS_ROOT'] )
      file ||= "structures.yml"
      write_file(File.expand_path(file, fixture_path), serialize_contents.to_yaml)
    end

    def self.write_file(path, content) # :nodoc:
      file = File.new(path, "w+")
      file.puts content
      file.close
    end

    # collects the contents of instances as a hash
    def self.serialize_contents
      @@structures.inject({}) do |hsh, arr|
        hsh.merge({arr.first.to_sym => arr.last.contents})
      end
    end

    # returns the contents of the instance variables as a hash
    def contents
      instance_variables.inject({}) do |hsh, var|
        hsh.merge({ var.tr('@', '').to_sym => instance_variable_get("#{var}") })
      end
    end
    
  end # Structure

end # Microformats