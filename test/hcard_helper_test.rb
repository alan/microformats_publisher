$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require(File.dirname(__FILE__) + "/../../../../config/environment")
require 'test/unit'
require 'microformats/helpers/microformat_helper'
require 'mocha'
require 'action_controller/assertions'

class HcardHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::CaptureHelper
  include Microformat::Helpers::ViewHelpers
  
  def setup
    
    geo = mock()
    geo.stubs(:latitude => 48.430092246,
                   :longitude => -123.364348450,
                   :attribute_names => ["longitude", "latitude"])
    
    tel2 = mock()
    tel2.stubs(:value => "+1-919-555-7878")
    
    email2 = mock()
    email2.stubs(:value =>  "jfriday@host.com")
    
    @hcard_micro = mock()
    @hcard_micro.stubs(:title => "Area Administrator, Assistant",
                                   :fn => "Joe Friday",
                                   :email => email2, 
                                   :tel => tel2,
                                   :photo => "http://www.factorycity.net/images/avatar.jpg",
                                   :geo => geo,
                                   :attribute_names => ["title", "tel", "fn", "url"],
                                   :url => "http://www.joefriday.com",
                                   :class => :HCard)
                                 
    @hcard2_micro = mock()
    @hcard2_micro.stubs(:fn => "Alan Kennedy",
                                     :url => "http://alan.com")
                                 
    n_model = mock()
    n_model.stubs(:given_name => "Joe",
                          :additional_name => "Marcus",
                          :family_name => "Friday",
                          :attribute_names => ["given_name", "additional_name", "family_name"])
    
    @hcard3_micro = mock()
    @hcard3_micro.stubs(:n => n_model,
                                     :attribute_names => [],
                                     :class => :HCard)
                                   
    org = mock()
    org.stubs(:organization_name => "CommerceNet",
                   :attributes_names => [])
    
    email = mock()
    email.stubs(:value => "info@commerce.net",
                      :attributes_names => [])
    
    
    tel = mock()
    tel.stubs(:types => "Work",
                 :value => "+1-650-289-4040",
                 :attributes_names => [])
               
    adr = mock()
    adr.stubs(:region => "California",
                   :street_address => "169 University Avenue",
                   :postal_code => "94301", 
                   :types => "Work",
                   :country_name => "USA", 
                   :locality => "Palo Alto",
                   :attribute_names => ["region", "street_address","postal_code","types","country_name","locality"])
    
    @hcard_adr = mock()
    @hcard_adr.stubs(:org => org,
                               :email => email,
                               :tel => tel,
                               :adr => adr,
                               :url => "http://www.commerce.net",
                               :attribute_names => [],
                               :class => :HCard)
                             
    org2 = mock()
    org2.stubs(:organization_name =>"Sprinkler Fitters U.A. Local 483",
                    :organization_unit => "Apprenticeship Training Center",
                    :attribute_names => ["organization_name", "organization_unit"])
    
    adr2 = mock()
    adr2.stubs(:street_address => "2531 Barrington Court",
                        :locality => "Hayward",
                        :region => "California",
                        :postal_code => "94545",
                        :attribute_names => ["region", "street_address","postal_code", "locality"])
    
    @hcard_org = mock()
    @hcard_org.stubs(:org => org2,
                               :adr => adr2,
                               :attribute_names => [],
                               :class => :HCard)
                             
    n2 = mock()
    n2.stubs(:given_name => "Fréderic",
                 :family_name => "de Villamil",
                 :attribute_names => ["given_name", "family_name"])
               
    email2 = mock()
    email2.stubs(:value =>"neuroNOSPAM@t37.net",
                       :etype => "pref",
                       :attribute_names => ["etype", "value"])
                     
    org2 = mock()
    org2.stubs(:organization_name => "Omatis")
    
    adr3 = mock()
    adr3.stubs(:country_name => "France",
                     :postal_code => "94270",
                     :locality => "Le Kremlin-Bicetre",
                     :street_address => "12 rue Danton",
                     :types => "home",
                     :attribute_names => ["types", "street_address", "locality", "postal_code", "country_name"])
                   
    geo2 = mock()
    geo2.stubs(:latitude => "48.816667" ,
                     :longitude =>"2.366667",
                     :attribute_names => ["latitude", "longitude"])
                             
    @hcard_mix_nesting = mock()
    @hcard_mix_nesting.stubs(:n => n2,
                                             :url => "http://t37.net",
                                             :nickname => "neuro",
                                             :email => email2,
                                             :class => :HCard,
                                             :org => org2,
                                             :adr => adr3,
                                             :geo => geo2,
                                             :attribute_names => ["nickname"])
  end
  
  def test_agent_card
    _erbout = ''   
    hcard_for(@hcard_micro, :type => :agent, :internal_tag => :div) do |hc|
      _erbout.concat hc.email_fn
      _erbout.concat hc.tel
      _erbout.concat hc.title
      _erbout.concat hc.url      
    end    
    expected = "<div class=\"agent vcard\">" +
                      "<a class=\"email fn\" href=\"mailto:jfriday@host.com\">Joe Friday</a>" +
                      "<div class=\"tel\">+1-919-555-7878</div>" +
                      "<div class=\"title\">Area Administrator, Assistant</div>" +
                      "<a href=\"http://www.joefriday.com\" class=\"url\">http://www.joefriday.com</a>"
                      "</div>"                    
    assert_dom_equal(expected, _erbout)
  end
  
  def test_url_fn_example
    _erbout = ''
    hcard_for(@hcard2_micro, :tag =>:address) do|hc|
      _erbout.concat hc.fn_url
    end
    expected = "<address class=\"vcard\">" +
                    "<a class=\"fn url\" href=\"http://alan.com\">Alan Kennedy</a>" +
                    "</address>"                  
    assert_dom_equal(expected, _erbout)    
  end

  def  test_fn_and_email_example
    _erbout = ''    
    hcard_for(@hcard_micro) do |hc|
      _erbout.concat hc.fn
      _erbout.concat hc.email
    end
    expected = "<div class=\"vcard\">" + 
                        "<span class=\"fn\">Joe Friday</span>"+
                        "<a href=\"mailto:jfriday@host.com\" class=\"email\">jfriday@host.com</a>" +
                      "</div>"
    assert_dom_equal(expected, _erbout)
  end
  
  def test_fn_n_example
    _erbout = ''
    hcard_for(@hcard3_micro) do |hc|
      hc.n_for :type => :fn, :tag => :span do |n|
        _erbout.concat n.given_name
        _erbout.concat n.additional_name
        _erbout.concat n.family_name
      end
    end
    expected = "<div class=\"vcard\">" + 
                        "<span class=\"fn n\">" +
                          "<span class=\"given-name\">Joe</span>" + 
                          "<span class=\"additional-name\">Marcus</span>" +
                          "<span class=\"family-name\">Friday</span>" +
                        "</span>" + 
                      "</div>"
    assert_dom_equal(expected, _erbout)
  end
  
  def test_fn_photo_example
    _erbout = ''
    hcard_for(@hcard_micro) do |hc|
      _erbout.concat hc.photo_fn
    end
    expected =  "<div class=\"vcard\">" +
                       "<img class=\"photo fn\" src=\"http://www.factorycity.net/images/avatar.jpg\" alt=\"Joe Friday\" />" +
                       "</div>"
     assert_dom_equal(expected, _erbout)
  end
  
  def test_geo_inclusion_example
    _erbout = ''
    hcard_for(@hcard_micro) do |hc|
      _erbout.concat hc.fn
      geo_for(hc.geo) do |g|
        _erbout.concat g.latitude
        _erbout.concat g.longitude
      end      
    end
    expected = "<div class=\"vcard\">" +
                        "<span class=\"fn\">Joe Friday</span>" +
                        "<div class=\"geo\">" +
                          "<span class=\"latitude\">48.430092246</span>" +
                          "<span class=\"longitude\">-123.36434845</span>" +
                        "</div>" +
                      "</div>"
    assert_dom_equal(expected, _erbout)
  end
  
  def test_adr_inclusion_example
    _erbout = ''
    hcard_for(@hcard_adr) do |hc|
      _erbout.concat hc.fn_org_url
      address_for hc.adr do |a|
        _erbout.concat(a.types)
        _erbout.concat a.street_address
        _erbout.concat(a.locality)
        _erbout.concat a.region(:internal_tag => :abbr, :display =>"CA")
        _erbout.concat a.postal_code
        _erbout.concat a.country_name
      end
      _erbout.concat hc.tel(:outer)
      _erbout.concat("<div>Email:")
      _erbout.concat hc.email(:text)
      _erbout.concat"</div>"
    end
    expected = "<div class=\"vcard\">" +
                        "<a class=\"fn org url\" href=\"http://www.commerce.net\">CommerceNet</a>" +
                        "<div class=\"adr\">" +
                          "<span class=\"type\">Work</span>" +
                          "<span class=\"street-address\">169 University Avenue</span>" +
                          "<span class=\"locality\">Palo Alto</span>" +
                          "<abbr class=\"region\" title=\"California\">CA</abbr>" + 
                          "<span class=\"postal-code\">94301</span>" +
                          "<span class=\"country-name\">USA</span>" +
                        "</div>" +
                      "<div class=\"tel\">" +
                        "<span class=\"type\">Work</span>+1-650-289-4040" +
                      "</div>" +
                      "<div>Email:" + 
                        "<span class=\"email\">info@commerce.net</span>" +
                      "</div>" +
                    "</div>"
    assert_dom_equal(expected, _erbout)
  end
  
  def test_org_inclusion
    _erbout=''
    hcard_for @hcard_org do |hc|
      hc.org_for :type =>:fn, :internal_tag => :div do |o|
        _erbout.concat o.organization_name
        _erbout.concat o.organization_unit
      end
    end
    
    expected = "<div class=\"vcard\">" +
                        "<div class=\"fn org\">" +
                           "<div class=\"organization-name\">Sprinkler Fitters U.A. Local 483</div>" + 
                           "<div class=\"organization-unit\">Apprenticeship Training Center</div>" +
                         "</div>" +
                      "</div>"
                    
    assert_dom_equal(expected, _erbout)
  end
  
  def test_adr_org_inclusion
    _erbout = ''
    
    hcard_for @hcard_org do |hc|
      address_for hc.adr(:internal_tag => :span) do |a|
        hc.org_for :type =>:fn, :internal_tag => :div do |o|
          _erbout.concat o.organization_name
          _erbout.concat o.organization_unit(:secondary_class => "extended-address")
        end
        _erbout.concat a.street_address(:internal_tag => :div)
        _erbout.concat a.locality + ","
        _erbout.concat a.region(:display => "CA", :internal_tag => :abbr)
        _erbout.concat a.postal_code
      end
    end
    
    expected = "<div class=\"vcard\">" +
                         "<div class=\"adr\">" +
                           "<div class=\"fn org\">" +
                             "<div class=\"organization-name\">Sprinkler Fitters U.A. Local 483</div>" +
                             "<div class=\"organization-unit extended-address\">Apprenticeship Training Center</div>" +
                           "</div>" +
                           "<div class=\"street-address\">2531 Barrington Court</div>" +
                           "<span class=\"locality\">Hayward</span>," + 
                           "<abbr title=\"California\" class=\"region\">CA</abbr>" +
                           "<span class=\"postal-code\">94545</span>" +
                         "</div>" +
                       "</div>"
                     
    assert_dom_equal(expected, _erbout)
  end
  
  def test_mixed_nesting
    _erbout = ''
    
    hcard_for(@hcard_mix_nesting) do |hc|
      hc.n_for( {:type => :fn, :tag => :span, :internal_tag => :span}) do |n|
        hc.url do
           _erbout.concat n.given_name
           _erbout.concat n.family_name
        end
      end
      _erbout.concat hc.nickname
      hc.email do |e|
        _erbout.concat e.etype({:tag => :span}) + "<span>erred email</span>"
      end
      _erbout.concat content_tag(:span, hc.org.organization_name, :class => 'org')
      address_for(hc.adr, :tag => :span) do |a|
        _erbout.concat a.types + " address: "
        _erbout.concat a.street_address
        _erbout.concat a.locality
        _erbout.concat a.postal_code
        _erbout.concat a.country_name
      end
      geo_for(hc.geo, :tag => :span, :internal_tag => :abbr) do |g|
        _erbout.concat g.latitude(:display => "N 48° 81.6667")
        _erbout.concat g.longitude(:display => "E 2° 36.6667")
      end      
    end
    
    expected = "<div class=\"vcard\">" +
                        "<span class=\"fn n\">" +
                          "<a class=\"url\" href=\"http://t37.net\">" +
                            "<span class=\"given-name\">Fréderic</span>" + 
                            "<span class=\"family-name\">de Villamil</span>" + 
                          "</a>" +
                        "</span>" +                     
                        "<span class=\"nickname\">neuro</span>" +
                        "<a class=\"email\" href=\"mailto:neuroNOSPAM@t37.net\">" +
                          "<span class=\"type\">pref</span><span>erred email</span>" +
                        "</a>" +                     
                        "<span class=\"org\">Omatis</span>" +
                        "<span class=\"adr\">" +
                          "<span class=\"type\">home</span> address: " +
                          "<span class=\"street-address\">12 rue Danton</span>" +
                          "<span class=\"locality\">Le Kremlin-Bicetre</span>" +
                          "<span class=\"postal-code\">94270</span>" +
                          "<span class=\"country-name\">France</span>" +
                        "</span>" +
                        "<span class=\"geo\">" +
                          "<abbr class=\"latitude\" title=\"48.816667\">N 48° 81.6667</abbr>" +
                          "<abbr class=\"longitude\" title=\"2.366667\">E 2° 36.6667</abbr>" +
                        "</span>" +
                      "</div>"

    assert_dom_equal(expected, _erbout)
  end
  
end
