module Microformat#:nodoc:
  module Helpers#:nodoc:
    module Validator#:nodoc:
      
      #Validator that validates any models or microformats that do not have anything to validate.
      class DummyValidator
        def initialize
          @validators = []
        end
        
        #Registers a call to a microformat.
        def call_to(name)
          @validators.delete(name.to_s)
        end
        
        #Stub method
        def valid?
          true
        end
      end
      
      # Validator for geo microfromats, checks that <tt>latitude</tt> and <tt>longitude</tt> have been called.
      class GeoValidator < DummyValidator      
        def initialize
          @validators = ["longitude", "latitude"]
        end
        
        #Checks that the geo is valid.
        def valid?
          return  @validators.empty?
        end
      end
      
      #Validator for adr microformat, there is no special requirement, but if there are any in the future they would be added to this class.
      class AdrValidator < DummyValidator
        def initialize
          @validators = [1]
        end
        
        def call_to(name = nil)
          @validators.pop
        end
        
        def valid?
          return @validators.empty?
        end
      end
      
      #Validator for hcard microformat. Checks that at least the attribute 'fn' or the model 'n' have been called.
      class HCardValidator < DummyValidator
        attr_writer :valid
        def initialize
          @validators = ["n", "fn"]
          @valid = false
        end
        
        #Returns true if the hcard is valid.
        def valid?
          return @valid || @validators.size == 1
        end
      end
      
      #Validator for hcalendar and event microformat and subformat. Checks that the starting date and summary are displayed.
      class HCalendarValidator < DummyValidator
        def initialize
          @validators = ["dtstart", "summary"]
        end
        
        #Returns true if the hcalendar is valid.
        def valid?
          return @validators.empty?
        end
      end
    end
  end
end