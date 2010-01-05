module Microformat
  module Helpers
    
    #== GenericHelper
    #
    # Module that contains generic methods to create view helpers for the microformats
    module GenericHelper
      
      # Provides the common functionality that a view helper microformat has.
      # It is meant to be used internally by the view helper, and not directly.
      def generic_for(object, options, options_for, message, &proc)
        raise ArgumentError unless block_given?
      
        containing_tag = options.delete(:tag) || :div
        internal_tag = options.delete(:internal_tag) || :span
        vclass = options.delete(:type).to_s
        vclass += " #{options.delete(:class) || options_for[:class]}"
        vclass.strip!
        internal_class = options_for[:internal_class]
        wrap_with_tag containing_tag, { :class => vclass }.merge(options), proc, message do
          internal = internal_class.new(internal_tag, object, self, proc.binding)
          yield internal
          internal.check_validity
        end
      end
    
      # Creates an html tag with content inside. Basically a content_tag with the difference that it can use a <em>microformat</em>InternalClass to provide its content.
      def wrap_with_tag(etag, options, proc, message = nil, &block)
        raise ArgumentError, "Missing block" unless block_given?
        concat tag(etag, options, true), proc.binding
        concat message, proc.binding unless message.nil?
        block.call
        concat "</#{etag}>", proc.binding
      end
    end
    
    #== GeoPublic
    #
    # Module providing the geo_for view helper method to display geo microformats.
    module GeoPublic
      include ::Microformat::Helpers::GenericHelper
  
      #Creates a geo microformat and scope for a specific geo microformat object, which is used to display its data in the microformat contents.
      #
      #object:: the microformat model to be displayed
      #options:: the hash display options for the microformat. The outer tag of the microformat is specified with the key :tag, and the internal tags with :internal_tag. By default these will be <tt><div>, <span></tt> respectevely.      #
      #message:: Text to follow after the opening outer tag.
      #
      #The method yields a <tt>GeoInternal</tt> object, which will validates the inner contents and provides finer control on how to display the data.
      #
      #An example could be:  
      #      
      #  <% geo_for @geo, {:tag => :div, :internal_tag => :span}, "GEO:" %> do |g|
      #    <%= g.latitude %>
      #    <%= g.longitude %>
      #  <% end %>
      #
      #Will generate, depending on the contents of @geo:
      #  
      # <div class="geo>GEO:
      #   <span class="latitude">0.444444</span>
      #   <span class="longitude">0.55555</span>
      # </div>
      #
      #Note that in this case using the default options would have generated the same output.
      def geo_for(object, options = {}, message = nil, &proc)
        raise ArgumentError, "Missing block" unless block_given?
      
        options_for = {:internal_class => ::Microformat::Helpers::MicroformatCreator::GeoInternal,
          :class => 'geo' }

        generic_for(object, options, options_for, message, &proc)
      end
    end
    
    #== AdrPublic
    #
    # Module providing the address_for view helper method to display adr microformats.
    module AdrPublic
      include GenericHelper
      
      #Creates an adr microformat and scope for a specific address microformat object, which is used to display its data in the microformat contents.
      #
      #object:: the microformat model to be displayed
      #options:: the hash display options for the microformat. The outer tag of the microformat is specified with the key :tag, and the internal tags with :internal_tag. By default these will be <tt><div>, <span></tt> respectevely.
      #message:: Text to follow after the opening outer tag.
      #
      #The method yields an <tt>AdrInternal</tt> object, which will validates the inner contents and provides finer control on how to display the data.
      #
      #An example could be:
      #
      # <% address_for(@address) do |a| %>
      #   <%= a.extended_address %>
      #   <%= a.street_address %>
      #   <%= a.locality %>
      #   <%= a.region %>
      #   <%= a.postal_code %>
      #   <%= a.country_name %>
      # <% end %>
      #
      #Will generate, depending of @address
      #
      # <div class="adr">
      #   <span class="extended-address">Flat C</span> 
      #   <span class="street-address">22 Goodge Street</span> 
      #   <span class="locality">London</span> 
      #   <span class="region">Middlesex</span>
      #   <span class="postal-code">WC1 4HX</span> 
      #   <span class="country-name">England</span>
      # </div>
      def address_for(object, options = {}, message = nil, &proc)
        raise ArgumentError unless block_given?
      
        options_for = {:internal_class =>::Microformat::Helpers::MicroformatCreator::AdrInternal,
          :class => 'adr'}
      
        generic_for(object, options, options_for, message, &proc)
      end
  
    end
    
    #== HCardPublic
    #
    # Module providing the hcard_for view helper method to display hcard microformats.
    module HCardPublic
      include GenericHelper
      
      #Creates an hcard microformat and scope for a specific address microformat object, which is used to display its data in the microformat contents.
      #
      #object:: the microformat model to be displayed
      #options:: the hash display options for the microformat. The outer tag of the microformat is specified with the key :tag, and the internal tags with :internal_tag. By default these will be <tt><div>, <span></tt> respectevely. Optionally, and specially for an <tt>hcard</tt> the :type key can be used to denote the type of microformat.
      #message:: Text to follow after the opening outer tag.
      #
      #The method yields an <tt>HCardInternal</tt> object, which will validates the inner contents and provides finer control on how to display the data.
      #
      #A simple example could be:
      #
      # <% hcard_for(@hcard) do |hc| %>
      #   <%= hc.fn %>
      # <% end %>
      #
      #Will generate, depending of @hcard:
      #
      # <div class="vcard">
      #   <span class="fn">Joe Friday</span>
      # </div>
      #
      #The defintion of hcard in www.microformats.org specifies some optimisations of which some are supported by <tt>hcard_for</tt>:
      #[fn_email] Generates an "a" element with the following structure <a class="email fn" href="mailto:hcard email address">fn attribute value</a>
      #[fn_url] Generates a link pointing to the <tt>url</tt> of the hcard using the <tt>fn</tt> attribute.
      #[fn_photo] Generates an img tag with the src attribute pointing to the <tt>url</tt> of the photo and the alt attribute having the <tt>fn</tt> attribute value
      #[fn_org_url]  Generates a link to the organisation website using its name to display it.
      #
      #An example using an optimisation could be:
      #
      # <% hcard_for(@hcard_micro, :type => "agent") do |hc| %>
      #   <%= hc.photo_fn %>
      # <% end %>
      #
      #Will generate, depending of @hcard:
      #
      # <div class=" agent vcard">
      #   <img class="photo fn" src="http://www.factorycity.net/images/avatar.jpg" alt="Joe Friday" />
      # </div>
      #
      #Note that the previous example makes use of the :type key in options to specify what type of hcard it is.
      #
      #An <tt>hcard</tt> can also have nested other models (email, url, n, org and tel) and microformats (adr and geo). See the hcard specification in www.microformats.org for more details.
      #
      #When including nested micformats, the helper methods address_for and geo_for can be called directly as:
      #
      # <% hcard_for @hcard do |h| %>
      #   <% geo_for @hcard.geo do |g| %>
      #   
      #The models can be called through methods to the <tt>HCardInternal</tt> yielded object.
      #
      #For more details on how to use these see:
      #Email:: Microformats::Helpers::SubFormatsHelper::Email            
      #Url:: Microformats::Helpers::SubFormatsHelper::Url
      #Org:: Microformats::Helpers::SubFormatsHelper::Org
      #Tel:: Microformats::Helpers::SubFormatsHelper::Tel
      #M:: Microformats::Helpers::SubFormatsHelper::N
      #
      def hcard_for(object, options = {}, message = nil, &proc)
        raise ArgumentError unless block_given?
      
        options_for = {:internal_class =>::Microformat::Helpers::MicroformatCreator::HCardInternal,
          :class => 'vcard'}
      
        generic_for(object, options, options_for, message, &proc)
      end
    end

    #== HCalendarPublic
    #
    # Module providing the hcalendar_for view helper method to display hcalendar microformats.
    module HCalendarPublic
      include GenericHelper
      
      #Creates an hcalendar microformat and scope for a specific hcalendar microformat object, which is used to display its data in the microformat contents.
      #
      #object:: the microformat model to be displayed
      #options:: the hash display options for the microformat. The outer tag of the microformat is specified with the key :tag, and the internal tags with :internal_tag. By default these will be <tt><div>, <span></tt> respectevely. Optionally, the :type key can be used to denote the type of microformat (see hcard_for) and :class to change the default class, the default for hcalendar_for is "vcalendar".
      #message:: Text to follow after the opening outer tag.
      #
      #The method yields an <tt>HCardInternal</tt> object, which will validates the inner contents and provides finer control on how to display the data.
      #
      #A simple example could be:
      #
      # <% hcalendar_for(@hcalendar, {:class =>"vevent"}) do |cal| %>
      #   <%= cal.url({:show => true}) %>
      #   <%= cal.summary %>:
      #   <%= cal.dtstart(:internal_tag => :abbr, :display => "October 5") %>-
      #   <%= cal.dtend(:internal_tag => :abbr, :display => "19") %>,
      #   at the <%= cal.location %>
      # <% end %>
      #
      #Will generate, depending of @hcalendar:
      #
      # <div class="vevent">"
      #   <a class="url" href="http://www.web2con.com/">htp://ww.web2con.com/</a>
      #   <span class="summary">Web 2.0 Conference</span>:
      #   <abbr class="dtstart" title="2007-10-05">October 5</abbr>-
      #   <abbr class="dtend" title="2007-10-20">19</abbr>,
      #   at the <span class="location">Argent Hotel, San Francisco, CA</span>
      # </div>
      # 
      #HCalendars can have a different number of events which can be invoked by calling <tt>event_for</tt> of Microformats::Helpers::SubFormatsHelper::HCalendar
      #To specify what event needs to be displayed a hash with the key :number mapping to the position of the event in the array returned by a field called <tt>events</tt>. This assumes that the events are ordered. [NOTE: The DSL specification of hcalendar does not specify nested HCalendars through events. This needs to be added after the generator.]
      #<tt>event_for</tt> has the same behaviour as hcalendar_for, so it could have further nested events.
      #
      #An example using nested events could be:
      #
      # <% hcalendar_for(@hcalendar, :class => :vcalendar) do |cal| %>
      #   <% cal.event_for(:number => 1) do |e|
      #     <%= e.dtstamp %>
      #      ...
      #      
      #Will generate, depending of @hcalendar:
      #
      # <div class="vcalendar">
      #   <div class="vevent">
      #     <span class="dtstamp">1997-03-24T12:00:00+00:00</span>      
      #
      def hcalendar_for(object, options ={}, message = nil, &proc)
        raise ArgumentError unless block_given?
      
        options_for = {:internal_class =>::Microformat::Helpers::MicroformatCreator::HCalendarInternal,
          :class => 'vevent'}
      
        generic_for(object, options, options_for, message, &proc)      
      end  
    end
  end
end