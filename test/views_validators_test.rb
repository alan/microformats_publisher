$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require(File.dirname(__FILE__) + "/../../../../config/environment")
require 'test/unit'
require 'microformats/helpers/microformat_helper'
require 'mocha'
require 'action_controller/assertions'

class ViewValidatorsTest < Test::Unit::TestCase
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::CaptureHelper
  include Microformat::Helpers::ViewHelpers

  def setup
    @geo = mock()
    @geo.stubs(:latitude => 3,
      :longitude => 4,
      :attribute_names => ["latitude", "longitude"])
                    
    @adr = mock()
    @adr.stubs(:street_address => "my street",
      :locality => "my city",
      :country_name => "my country",
      :region => nil,
      :extended_address => "  ",
      :attribute_names => ["locality", "street_address", "country_name", "extended_address", "region"])
                       
    geo = mock()
    geo.stubs(:latitude => 48.430092246,
      :longitude => -123.364348450,
      :attribute_names => ["longitude", "latitude"])
    
    tel2 = mock()
    tel2.stubs(:value => "+1-919-555-7878")
    
    email2 = mock()
    email2.stubs(:value =>  "jfriday@host.com")
    
    n_model = mock()
    n_model.stubs(:given_name => "Joe",
      :additional_name => "Marcus",
      :family_name => "Friday",
      :attribute_names => ["given_name", "additional_name", "family_name"])
                        
    org = mock()
    org.stubs(:organization_name => "CommerceNet",
      :attribute_names => ["organization_name"])
    
    @hcard = mock()
    @hcard.stubs(:title => "Area Administrator, Assistant",
      :fn => "Joe Friday",
      :email => email2,
      :url => "http://www.joefriday.com",
      :tel => tel2,
      :photo => "http://www.factorycity.net/images/avatar.jpg",
      :geo => geo,
      :n => n_model,
      :org => org,
      :attribute_names => ["title", "tel", "fn"],
      :class => :HCard)
    
    event = mock()
    event.stubs(:summary => "Calendaring Interoperability Planning Meeting",
                      :dtstart => DateTime.new(1997, 3, 24, 12, 30, 0,0),
                      :attribute_names => ["summary","dtstart"])
    
    @hcalendar = mock()
    @hcalendar.stubs(:url =>"http://www.web2con.com/",
                               :summary =>"Web 2.0 Conference",
                               :dtstart => Date.new(2007, 10, 5), #needs work # maybe not
                               :dtend => Date.new(2007, 10, 20),
                               :location => "Argent Hotel, San Francisco, CA",
                               :events => [event],
                               :attribute_names => ["url", "summary", "dtstart", "dtend", "location", "location"])
  end
  
  def test_adr_skipping_nil_and_empty_attributes
    _erbout = ''   
    address_for(@adr) do |a|
      _erbout.concat a.street_address
      _erbout.concat a.extended_address
      _erbout.concat a.locality
      _erbout.concat a.region
      _erbout.concat a.country_name      
    end    
    expected = "<div class=\"adr\">" +
                      "<span class=\"street-address\">my street</span>" + 
                      "<span class=\"locality\">my city</span>" + 
                      "<span class=\"country-name\">my country</span></div>"    
    assert_dom_equal(expected, _erbout)   
  end
  
  def test_invalid_geo
    assert_raise(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout =''
      geo_for(@geo) do |g|
        _erbout.concat g.latitude
      end
    end
  end
  
  def test_valid_geo
    assert_nothing_raised(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout =''
      geo_for(@geo) do |g|
        _erbout.concat g.latitude
        _erbout.concat g.longitude
      end
    end
  end
  
  def test_invalid_adr
    assert_raise(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout = ''
      address_for(@adr) {} 
    end
  end
  
  def test_valid_adr
    assert_nothing_raised(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout = ''
      address_for(@adr) do |g|
        _erbout.concat g.street_address
        _erbout.concat g.locality
        _erbout.concat g.country_name
      end
    end
  end
  
  def test_invalid_hcard
    assert_raise(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout = ''
      hcard_for(@hcard) do |h|
        _erbout.concat h.title
      end
    end
  end
  
  def test_valid_hcard_with_fn
    assert_nothing_raised(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout =''
      hcard_for(@hcard) do |h|
        _erbout.concat h.fn
      end
    end
  end
  
  def test_valid_hcard_with_n
    assert_nothing_raised(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout = ''
      hcard_for(@hcard) do |h|
        h.n_for do |n|
          _erbout.concat n.given_name
        end
      end
    end
  end
  
  def test_valid_hcard_with_fn_email
    assert_nothing_raised(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout = ''
      hcard_for(@hcard) do |h|
        _erbout.concat h.email_fn
      end
    end
  end
  
  def test_valid_hcard_with_fn_url
    assert_nothing_raised(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout = ''
      hcard_for(@hcard) do |h|
        _erbout.concat h.url_fn
      end
    end
  end
  
  def test_valid_hcard_with_fn_photo
    assert_nothing_raised(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout = ''
      hcard_for(@hcard) do |h|
        _erbout.concat h.fn_photo
      end
    end
  end
  
  def test_valid_hcard_with_fn_org_url
    assert_nothing_raised(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout = ''
      hcard_for(@hcard) do |h|
        _erbout.concat h.fn_org_url
      end
    end
  end
  
  def test_valid_hcard_with_nested_org_fn
    assert_nothing_raised(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout=''
      hcard_for(@hcard) do |hc|
        hc.org_for :type =>:fn do |o|
          _erbout.concat o.organization_name
        end
      end
    end
  end
  
  def test_invalid_hcard_with_nested_org
    assert_raise(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout=''
      hcard_for(@hcard) do |hc|
        hc.org_for :type =>:nfn do |o| # incorrect type
          _erbout.concat o.organization_name
        end
      end
    end    
  end
  
  def test_valid_geo_nested_in_hcard
    _erbout = '' 
    assert_nothing_raised(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do 
      hcard_for(@hcard) do |h|
        _erbout.concat h.fn
        geo_for(h.geo) do |g|
          _erbout.concat g.latitude
          _erbout.concat g.longitude
        end
      end
    end
  end
  
  def test_invalid_geo_nested_in_hcard
    _erbout = '' 
    assert_raise(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do 
      hcard_for(@hcard) do |h|
        _erbout.concat h.fn
        geo_for(h.geo) do |g|
          _erbout.concat g.latitude
        end
      end
    end
  end
  
  def test_valid_hcalendar
    assert_nothing_raised(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout =''
      hcalendar_for(@hcalendar) do |cal|
        _erbout.concat cal.summary
        _erbout.concat cal.dtstart
      end
    end
  end
  
  def test_invalid_hcalendar
    assert_raise(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout =''
      hcalendar_for(@hcalendar) do |cal|
        _erbout.concat cal.summary
      end
    end
  end
  
  def test_valid_nested_calendar_event
    assert_nothing_raised(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout =''
      hcalendar_for(@hcalendar) do |cal|
        cal.event_for(:number => 1) do |e|
        _erbout.concat e.summary
        _erbout.concat e.dtstart          
        end
      end
    end
  end
  
  def test_invalid_nested_calendar_event
    assert_raise(Microformat::Helpers::MicroformatCreator::MicroformatInternalNotValid) do
      _erbout =''
      hcalendar_for(@hcalendar) do |cal|
        cal.event_for(:number => 1) do |e|
        _erbout.concat e.summary      
        end
      end
    end
  end
end