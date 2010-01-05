$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require(File.dirname(__FILE__) + "/../../../../config/environment")
require 'test/unit'
require 'microformats/helpers/microformat_helper'
require 'mocha'
require 'action_controller/assertions'

class AddressHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::CaptureHelper
  include Microformat::Helpers::ViewHelpers
  
  def setup
    @adr_micro = mock()
    @adr_micro.stubs(:region => "Middlesex",
                                :street_address => "22 Goodge Street", 
                                :extended_address => "Flat C",
                                :postal_code => "WC1 4HX", 
                                :types => "HOME",
                                :country_name => "England", 
                                :locality => "London",
                                :post_office_box => "None",
                                :attribute_names => ["region", "street_address","extended_address","postal_code","types","country_name","locality","post_office_box"])
    
    @adr_example = mock()
    @adr_example.stubs(:region => "California",
                                    :country_name => "United States",
                                    :attribute_names => ["region", "country_name"])
                                  
    @adr_example2 = mock()
    @adr_example2.stubs(:locality => "Salem",
                                      :attribute_names => ["locality"])
  end
  
  def test_adr_without_any_arguments_or_options
     _erbout = ''   
    address_for(@adr_micro) do |a|
      _erbout.concat a.extended_address
      _erbout.concat a.street_address
      _erbout.concat a.locality
      _erbout.concat a.region
      _erbout.concat a.postal_code
      _erbout.concat a.country_name      
    end    
    expected = "<div class=\"adr\">" +
                      "<span class=\"extended-address\">Flat C</span>" + 
                      "<span class=\"street-address\">22 Goodge Street</span>" + 
                      "<span class=\"locality\">London</span>" + 
                      "<span class=\"region\">Middlesex</span>" + 
                      "<span class=\"postal-code\">WC1 4HX</span>" + 
                      "<span class=\"country-name\">England</span></div>"    
    assert_dom_equal(expected, _erbout)
  end
  
  def test_adr_passing_text
    _erbout = ''   
    address_for(@adr_micro, {}, "Home address:") do |a|
      _erbout.concat a.extended_address
      _erbout.concat a.street_address
      _erbout.concat a.locality
      _erbout.concat a.region
      _erbout.concat a.postal_code
      _erbout.concat a.country_name      
    end    
    expected = "<div class=\"adr\">Home address:" +
                      "<span class=\"extended-address\">Flat C</span>" + 
                      "<span class=\"street-address\">22 Goodge Street</span>" + 
                      "<span class=\"locality\">London</span>" + 
                      "<span class=\"region\">Middlesex</span>" + 
                      "<span class=\"postal-code\">WC1 4HX</span>" + 
                      "<span class=\"country-name\">England</span></div>"    
    assert_dom_equal(expected, _erbout)   
  end
  
  def test_adr_website_example
     _erbout = ''   
    address_for(@adr_example, {:tag => :span, :internal_tag=> :abbr}) do |a|
      _erbout.concat a.region(:display => "CA") + ","
      _erbout.concat a.country_name(:display => "US")      
    end    
    expected = "<span class=\"adr\">" +
                      "<abbr class=\"region\" title=\"California\">CA</abbr>," +
                      "<abbr class=\"country-name\" title=\"United States\">US</abbr>" +
                      "</span>"
    assert_dom_equal(expected, _erbout)
  end
  
  def test_adr_website_example2
    _erbout = ''   
    address_for(@adr_example2, {:tag => :p}, "Unbelievable. Yesterday's high temperature in ") do |a|
      _erbout.concat a.locality + " it was 57 degrees out."              
    end
    expected = "<p class=\"adr\">Unbelievable. Yesterday's high temperature in " +
      "<span class=\"locality\">Salem</span> it was 57 degrees out.</p>"
    assert_dom_equal(expected, _erbout)
  end
  
end
