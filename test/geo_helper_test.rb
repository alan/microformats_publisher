$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require(File.dirname(__FILE__) + "/../../../../config/environment")
require 'test/unit'
require 'microformats/structures'
require 'microformats/helpers/microformat_helper'
require 'mocha'
require 'action_controller/assertions'

class GeoHelperTest < Test::Unit::TestCase
  include Microformats
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::CaptureHelper
  include Microformat::Helpers::ViewHelpers

  
  def setup
    
    @geo_microformat = mock()
    @geo_microformat.stubs(:latitude => "51.5322", 
                                              :longitude => "-0.111157",
                                              :attribute_names => ["latitude", "longitude"])
                                            
    @geo_microformat2 = mock()
    @geo_microformat2.stubs(:latitude => "55", 
                                              :longitude => "44",
                                              :attribute_names => ["latitude", "longitude"])
     
  end
  
  def test_geo_for_with_arguments    
    _erbout = ''   
    geo_for(@geo_microformat, {:tag => :div, :internal_tag => :span}, "GEO:") do |g|
      _erbout.concat g.latitude(:display => "#{@geo_microformat.latitude}")
      _erbout.concat g.longitude(:display => "#{@geo_microformat.longitude}")
    end
    expected =   "<div class=\"geo\">GEO:" +
                        "<span class=\"latitude\"  title=\"51.5322\">51.5322</span>" +  
                        "<span class=\"longitude\" title=\"-0.111157\">-0.111157</span>" +
                        "</div>"    
    assert_dom_equal(expected, _erbout)    
  end
  
  def test_geo_for_without_arguments    
    _erbout = ''    
    geo_for(@geo_microformat2, {:tag => :div, :internal_tag => :span}, "GEO:") do |g|
      _erbout.concat g.latitude
      _erbout.concat g.longitude
    end    
    expected =   "<div class=\"geo\">GEO:" +
                        "<span class=\"latitude\">55</span>" +  
                        "<span class=\"longitude\">44</span>" +
                        "</div>"                      
    assert_dom_equal(expected, _erbout)
  end
  
  def test_geo_for_without_html_options
    _erbout = ''
    geo_for(@geo_microformat2,{}, "GEO:") do |g|
      _erbout.concat g.latitude
      _erbout.concat g.longitude
    end
    expected =   "<div class=\"geo\">GEO:" +
                        "<span class=\"latitude\">55</span>" +  
                        "<span class=\"longitude\">44</span>" +
                        "</div>"  
    assert_dom_equal(expected, _erbout)
  end
  
  def test_geo_for_without_any_options
    _erbout = ''
    geo_for(@geo_microformat2) do |g|
      _erbout.concat g.latitude
      _erbout.concat g.longitude
    end
    expected =   "<div class=\"geo\">" +
                        "<span class=\"latitude\">55</span>" +  
                        "<span class=\"longitude\">44</span>" +
                        "</div>"  
    assert_dom_equal(expected, _erbout)    
  end
  
  def test_geo_with_different_tags
    _erbout = ''
    geo_for(@geo_microformat2, {:tag => :p, :internal_tag => :div}) do |g|
      _erbout.concat g.latitude
      _erbout.concat g.longitude
    end
    expected =   "<p class=\"geo\">" +
                        "<div class=\"latitude\">55</div>" +  
                        "<div class=\"longitude\">44</div>" +
                        "</p>"  
    assert_dom_equal(expected, _erbout)        
  end
  
  def test_geo_with_partial_tags
    _erbout = ''
    geo_for(@geo_microformat2, {:tag => :p}) do |g|
      _erbout.concat g.latitude
      _erbout.concat g.longitude
    end
    expected =   "<p class=\"geo\">" +
                        "<span class=\"latitude\">55</span>" +  
                        "<span class=\"longitude\">44</span>" +
                        "</p>"  
    assert_dom_equal(expected, _erbout)        
  end
  
end
