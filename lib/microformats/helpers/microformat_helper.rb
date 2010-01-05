module Microformat #:nodoc:
  module Helpers #:nodoc:

    #==ViewHelpers
    # 
    # This module is accessible from ActionView, modules with view helpers included to this module will be available in the views.
    # Modules are included manually, in ffuture revisions this will done dinamically by the DSL in the plugin.
    # 
    #-- 
    # TODO To be added depending on DSL
    module ViewHelpers
      
      include GeoPublic
      include AdrPublic
      include HCardPublic
      include HCalendarPublic
    end
    
    
    module MicroformatCreator #:nodoc:
    
      #== InvalidMicroformatField
      #
      #Exception thrown when an attribute called by the microformat helper does not exist.
      # 
      #Example:
      #
      # geo attributes: latitude, longitude
      #
      # <% geo_for(@geo_object) do |g| %>
      #   <%= g.something %> => Exception is thrown.    
      class InvalidMicroformatField < StandardError
      end
    
      #==MicroformatInternalNotValid
      #
      #Exception thrown when the microformat requirements as described in www.microformats.org are not met by a helper call.
      #In future revisions the required fields might be described in the DSL.
      #
      class MicroformatInternalNotValid < StandardError
      end
    
      #== Microformat
      #
      #Generic class for the Internal classes of the Microformats.
      # 
      #The main purpose of this class is its method_missing, which generates methods for a microformat internal class depending on their definition.
      #
      #It is not suppoused to be used directly, its meant to be subclassed by a <em>microformat</em>Internal class.
      class Microformat
        include ActionView::Helpers::TagHelper
        include ActionView::Helpers::CaptureHelper
        include ActionView::Helpers::TextHelper
        include ActionView::Helpers::UrlHelper
        include ActionView::Helpers::AssetTagHelper
        
        #Creates an <em>microformat</em>internal with the default internal tag, microformat object, template and binding to ActionView::Base. 
        def initialize(tag, object, template, local_binding)
          @internal_tag, @object, @template = tag, object, template, local_binding
          @local_binding = eval("self.class", local_binding).to_s == "ActionView::Base" ? local_binding : eval("@local_binding", local_binding)        
        end
      
        #Validates the microformat based on what attributes and classes are going to be displayed.
        def check_validity
          unless @validator.valid? 
            raise MicroformatInternalNotValid, "The microformat does not have the required html classes"
          end
        end 
      
        #Defines new methods based on the microformat models, or returns a nested microformat.
        #
        #Creates methods based on the attributes, so if a microformat has an attribute called 'longitude' it will create and call a method call 'longitude'
        #These methods take an options hash which can modify the html generated.
        #The keys of the hash that are valid are:
        #[:internal_tag] to change the html tag specified in the <tt>microformat_for</tt> method.
        #[:display] to change the contents to show, useful for the geo microformat, to display human readable coordinates.
        #[:secondary_class] to provide an extra class to the html tag.
        #
        def method_missing(name, *args)
          attributes = @object.attribute_names.collect { |a| a.to_sym }
          case name
        
            # The method name is an attribute in the ActiveRecord model
          when *attributes
          
            block = Proc.new do |*argument|
              
              # Do not display tags for a nil value
              unless @object.send(name).blank?
              
                # Tell validator that an attribute has been displayed.
                @validator.call_to(to_class(name))
            
                argument.flatten!
                options = (argument.empty?) ? {} :argument.pop
                internal_tag = options[:internal_tag] || @internal_tag
                tag_class = to_class(name)
                tag_class = tag_class + " " + options[:secondary_class]  if options.has_key? :secondary_class
                if options.has_key? :display
                  content_tag(internal_tag, options[:display], :class => tag_class, 
                    :title => "#{@object.send(name)}" )              
                else          
                  content_tag(internal_tag, "#{@object.send(name)}", :class => tag_class)
                end
              else
                "" # Required to make the tests work with nil values
              end
            end
          
            create_and_call_method(name, block, args)
        
            # Return the subformat or model requested.
          when *sub_formats
            @object.send(name, args)
          else
            # Method call name is not an attribute of AR or subformat, so it's an invalid microformat field.
            raise InvalidMicroformatField, "The field #{name} does not exist for #{@object.class}"      
          end
              
        end
      
        private
      
        # Converts the name of the method call to a microformat compliant html class attribute.
        def to_class(name)
          if name == :types || name == :etype
            result = "type"
          elsif name == :nicknames
            result = "nickname"
          else
            result = name.to_s.gsub('_','-')
          end
          result
        end

        def create_and_call_method(name, block, args)
          self.class.send(:define_method, name, block)
          block.call args
        end
      
        # Returns an array with the models that the microformat object being displayed can use according to its
        # definition in the DSL.
        def sub_formats
          klass_name = @object.class.to_s
          structure = Microformats::Structure.get(klass_name)
          structure.models.collect!{|e| e.to_sym}
        rescue
          false
        end
      end
    
      #== GeoInternal
      #
      # Provides methods that display the internal data of a Geo microformat.    
      class GeoInternal < Microformat
        def initialize(tag, object, template, local_binding)
          @validator = Helpers::Validator::GeoValidator.new
          super(tag, object, template, local_binding)
        end 
      end
    
      #== AdrInternal
      #
      # Provides methods that display the internal data of an Adr microformat.
      class AdrInternal < Microformat      
        def initialize(tag, object, template, local_binding)
          @validator = Helpers::Validator::AdrValidator.new
          super(tag, object, template, local_binding)
        end
      end
    
      #== OrgInternal
      #
      # Provides methods that display the internal data of an Org microformat.
      class OrgInternal < Microformat
        def initialize(tag, object, template, local_binding)
          @validator = Helpers::Validator::DummyValidator.new
          super(tag, object, template, local_binding)
        end
      end
    
   
      #== NInternal 
      #
      # Provides methods that display the internal data of an N model of an HCard microformat.
      class NInternal < Microformat
        def initialize(tag, object, template, local_binding)
          @validator = Helpers::Validator::DummyValidator.new
          super(tag, object, template, local_binding)
        end
      end
    
      #== EmailInternal
      #
      # Provides methods that display the internal data of an Email model of an HCard microformat.
      class EmailInternal < Microformat
        def initialize(tag, object, template, local_binding)
          @validator = Helpers::Validator::DummyValidator.new
          super(tag, object, template, local_binding)
        end
      end
    
      #== HCalendarInternal
      #
      # Provides methods that display the internal data of an HCalendar microformat.
      class HCalendarInternal < Microformat
        include Microformats::Helpers::SubFormatsHelper::Url
        include Microformats::Helpers::SubFormatsHelper::HCalendar
       
        def initialize(tag, object, template, local_binding)
          @validator = Helpers::Validator::HCalendarValidator.new
          super(tag, object, template, local_binding)
        end
      end
    
      #== HCardInternal
      #
      #  Provides methods that display the internal data of an HCard microformat
      class HCardInternal < Microformat
        include Microformats::Helpers::SubFormatsHelper::Tel
        include Microformats::Helpers::SubFormatsHelper::Email
        include Microformats::Helpers::SubFormatsHelper::Url
        include Microformats::Helpers::SubFormatsHelper::N
        include Microformats::Helpers::SubFormatsHelper::Org
      
        def initialize(tag, object, template, local_binding)
          @validator = Helpers::Validator::HCardValidator.new
          super(tag, object, template, local_binding)
        end
      
        # Checks if there is an optimisation, otherwise calls the parent method.
        def method_missing(name, *args, &block)
         
          optimisation = optimisation? name
          if optimisation
            @validator.valid = true
            return optimisation 
          else
            super
          end
        end
      
        private
       
        # Returns the html code for the view if there is an optimisation, otherwise will return nil.
        def optimisation?(name)
          if(check_for_fn_email(name))
            mail_to(@object.email.value, @object.fn, {:class => to_html_class(name)})
          elsif(check_for_fn_url(name))
            link_to(@object.fn, @object.url, {:class => to_html_class(name)})
          elsif(check_for_fn_photo(name)) #make possible to include size picture in options
            image_tag(@object.photo, :alt => @object.fn, :class => to_html_class(name))
          elsif(check_for_fn_org_url(name))
            link_to(@object.org.organization_name, @object.url, {:class => to_html_class(name)})
          end
        end
      
        # Returns a suitable html class name for an optimisation.
        def to_html_class(name)
          name.to_s.gsub('_', ' ')
        end
      
        # Looks for a "fn email" optimisiation.
        def check_for_fn_email(name)
          words = name.to_s.split('_')
          return false unless words.size == 2
          return words.include?("fn") && words.include?("email")
        end
      
        # Looks for a "fn url" optimisation.
        def check_for_fn_url(name)
          words = name.to_s.split('_')
          return false unless words.size == 2
          return words.include?("fn") && words.include?("url")
        end
      
        # Looks for a "fn photo" opimisation.
        def check_for_fn_photo(name)
          words = name.to_s.split('_')
          return false unless words.size == 2
          return words.include?("fn") && words.include?("photo")
        end
      
        # Looks for a "fn org url" optimisation.
        def check_for_fn_org_url(name)
          words = name.to_s.split('_')
          return false unless words.size == 3
          return words.include?("fn") && words.include?("org") && words.include?("url")
        end
      end
    end
  end
end