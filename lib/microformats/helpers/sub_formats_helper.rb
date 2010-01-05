module Microformats
  module Helpers
    module SubFormatsHelper#:nodoc:
      include ActionView::Helpers::TagHelper
      
      # Provides the method org_for for nesting <tt>org</tt> models in hcards.
      module Org
        
        #Used to display nested org models in hcards. It provides similar functionlity of the other <tt>microformat</tt>_for methods.
        #
        #An example of its use in an hcard could be:
        #
        # <% hcard_for @hcard do |hc| %>
        #   <% hc.org_for :type =>:fn, :internal_tag => :div do |o| %>
        #      <%= o.organization_name %>
        #      <%= o.organization_unit %>
        #   <% end %>
        # <% end %>
        # 
        #Will generate, depending of @hcard:
        #
        # <div class="vcard">
        #   <div class="fn org">
        #     <div class="organization-name">Sprinkler Fitters U.A. Local 483</div> 
        #     <div class="organization-unit">Apprenticeship Training Center</div>
        #   </div>
        # </div>
        #        
        def org_for( options ={}, message =nil, &proc)
          raise ArgumentError unless block_given?
          
          @validator.call_to(options[:type])
          options_for = {:internal_class =>::Microformat::Helpers::MicroformatCreator::OrgInternal,
                               :class => 'org'}
          generic_for(@object.org, options, options_for, message, &proc)
        end
      end
      
      #Provides the method n_for for nesting <tt>n</tt> models in hcards.
      module N
        include Microformat::Helpers::GenericHelper
        
        #Used to display nested n models in hcards. It provides similar functionlity of the other <tt>microformat</tt>_for methods.
        #
        #An example of its use in an hcard could be:
        #
        # <% hcard_for(@hcard) do |hc| %>
        #   <% hc.n_for :type => :fn, :tag => :span do |n| %>
        #      <%= n.given_name %>
        #      <%= n.additional_name %>
        #      <%= n.family_name %>
        #   <% end %>
        # <% end %>
        #
        #Will generate, depending of @hcard:
        #
        # <div class="vcard"> 
        #   <span class="fn n">
        #     <span class="given-name">Joe</span> 
        #     <span class="additional-name">Marcus</span>
        #     <span class="family-name">Friday</span>
        #   </span> 
        # </div>
        #
        def n_for( options = {}, message = nil, &proc)
          raise ArgumentError, "Missing block" unless block_given?
          
          @validator.call_to(:n)
          options_for = {:internal_class =>::Microformat::Helpers::MicroformatCreator::NInternal,
                               :class => 'n'}
          generic_for(@object.n, options, options_for, message, &proc)
        end
      end
      
      #Provides the method event_for for nesting <tt>hcalendars</tt> events in a hcalendar.
      module HCalendar
        include Microformat::Helpers::HCalendarPublic
        
        #Please see <tt>hcalendar_for</tt> documentation in Microformat::Helpers::HCalendarPublic to see the how to use event_for.
        def event_for(options = {}, message = nil, &proc)
          @validator.call_to(:dtstart)
          @validator.call_to(:summary)
          events = @object.events
          object = events[options.delete(:number) - 1]
          hcalendar_for(object, options, message, &proc)        
        end
      end
      
      #Provides the method url to display urls in hcards.
      module Url
        include ActionView::Helpers::UrlHelper
        
        #When passed block, it will create a link to the value of the url attribute displaying the contents of the block.
        #
        #An example of its use could be:
        #
        # <% hcard_for(@hcard) do |hc| %>
        #   <% hc.n_for( {:type => :fn, :tag => :span, :internal_tag => :span}) do |n|
        #     <% hc.url do
        #         <%= n.given_name
        #         <%= n.family_name
        #       <%end
        #       ...
        #       
        #Will produce depending on the data of the objects:
        #
        # <div class="vcard">
        #   <span class="fn n">
        #     <a class="url" href="http://t37.net">
        #       <span class="given-name">Fréderic</span> 
        #       <span class="family-name">de Villamil</span> 
        #     </a>
        #   ...
        #   
        #If it isn't passed a block, it will link to the url, displaying the url at the same time.   
        #   
        def url(options = {}, &proc)
          if block_given?       
            wrap_with_tag :a, { :class => 'url', :href => @object.url }.merge(options), proc do
              yield 
            end
          else
            link_to(@object.url, @object.url, {:class => 'url'}) 
          end
        end        
      end
      
      #Provides the method tel to display telphones in hcards.      
      module Tel
        
        #Takes an optional parameter that determines how to display the telephone number.
        # 
        #When it does not take a parameter, it creates a tag of the internal_tag key in hcard_for with the tel attribute value, will produce something similar to:  <div class="tel">+1-919-555-7878</div>
        # 
        #When taking a parameter, the value permited is :outer which creates two nested tags, the outer being a div tag with 'tel' class, and the inner specifying the type of the telephone.
        #
        #An example of :outer use would be:
        #
        # <% hcard_for(@hcard) do |hc| %>
        #    <% hc.tel :outer %>
        #    ...
        #    
        #Will produce html similar to
        #
        # <div class="vcard"> 
        #   <div class="tel">" +
        #     <span class="type">Work</span>+1-650-289-4040
        #   </div>
        #   ...
        #
        #--
        #TODO - Improve the :outer option to specify its tags. Take the email approach with a block if possible.
        #
        def tel(option = nil)
          case option        
          when nil
            content_tag(@internal_tag, "#{@object.tel.value}", :class => "tel")        
          when :outer
            content_tag("div", {:class => "tel"}) do
              content_tag(@internal_tag, "#{@object.tel.types}", :class => "type") + "#{@object.tel.value}"
            end
          end
        end
      end
      
      #Provides the method email to display emails in hcards.       
      module Email
        
        # It can take an optional block, which can be used to specify what to display inside the link mailto.
        #
        #An example of this use would be:
        #
        # <% hcard_for(@hcard) do |hc| %>
        #    <% hc.email do |e| %>
        #      <%= e.etype({:tag => :span}) %> <span>erred email</span>
        #    <% end %>
        #    ...
        #
        #Will produce html similar to
        #
        # <div class="vcard">
        #   <a class="email" href="mailto:neuroNOSPAM@t37.net">
        #     <span class="type">pref</span><span>erred email</span>
        #   </a>
        # ...
        #
        #When is not used with a block, there are two possible option for the argument, no argument and :text as the argument.
        #
        #With no argument, it produces a link to the email address. With :text, it displays the email address but with no link.
        #
        def email(options = {}, &proc)
          if block_given?
            internal_tag = options.delete(:internal_tag) || :span        
            wrap_with_tag :a, {:class => 'email', :href => "mailto:#{@object.email.value}"}.merge(options), proc do
              yield ::Microformat::Helpers::MicroformatCreator::EmailInternal.new(internal_tag, @object.email, self, proc.binding)
            end
          else
            case options
            when {}
              mail_to(@object.email.value, @object.email.value, {:class => "email"}) 
            when :text
              content_tag(@internal_tag, "#{@object.email.value}", :class => "email")
            end
          end
        end    
      end
    
    end
end
end
