$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require(File.dirname(__FILE__) + "/../../../../config/environment")
require 'test/unit'
require 'microformats/helpers/microformat_helper'
require 'mocha'
require 'action_controller/assertions'

class HCalendarHelperTest < Test::Unit::TestCase
  include Microformat::Helpers::ViewHelpers
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  
  def setup
    @hcalendar = mock()
    @hcalendar.stubs(:url =>"http://www.web2con.com/",
                               :summary =>"Web 2.0 Conference",
                               :dtstart => Date.new(2007, 10, 5),
                               :dtend => Date.new(2007, 10, 20),
                               :location => "Argent Hotel, San Francisco, CA",
                               :attribute_names => ["url", "summary", "dtstart", "dtend", "location", "location"])
 
  @hcalendar2 = mock()
  @hcalendar2.stubs(:summary => "XYZ Project Review",
                               :description => "Project XYZ Review Meeting",
                               :dtstart => DateTime.new(1998, 3, 12, 8, 30, 0,0),
                               :dtend => DateTime.new(1998, 3, 12, 9, 30, 0),
                               :dtstamp => DateTime.new(1998, 3, 9),
                               :uid => "guid-1.host1.com",
                               :location => "1CP Conference Room 4350",
                               :attribute_names => ["summary", "description", "dtstart", "dtend", "dtstamp", "uid", "location"])
     
    event = mock()
    event.stubs(:summary => "Calendaring Interoperability Planning Meeting",
                      :description => "Discuss how we can test c&s interoperability using iCalendar and other IETF standards.",
                      :dtstart => DateTime.new(1997, 3, 24, 12, 30, 0,0),
                      :dtend => DateTime.new(1997, 3, 24, 21, 30, 0),
                      :uid => "uid3@host1.com",
                      :dtstamp => DateTime.new(1997, 3, 24,12,0,0),
                      :location => "LDB Lobby",
                      :sequence => "0",
                      :organizer => "jdoe@host1.com",
                      :attendee => "jsmith@host1.com",
                      :attribute_names => ["summary","description","dtstart","dtend","uid","dtstamp","location","sequence", "organizer", "attendee"])
    
    @hcalendar3 = mock()
    @hcalendar3.stubs(:method => "xyz",
                                 :events => [event],
                                 :attribute_names => ["method", "events"])
    
    
  end
  
  def test_simple_hcalendar
    _erbout =''
    
    hcalendar_for(@hcalendar, {:class =>"vevent"}) do |cal|
      _erbout.concat cal.url
      _erbout.concat cal.summary + ":"
      _erbout.concat cal.dtstart(:internal_tag => :abbr, :display => "October 5") + "-"
      _erbout.concat cal.dtend(:internal_tag => :abbr, :display => "19") + ","
      _erbout.concat(" at the ") + _erbout.concat(cal.location)
    end
    
    expected = "<div class=\"vevent\">" +
                        "<a class=\"url\" href=\"http://www.web2con.com/\">http://www.web2con.com/</a>" +
                        "<span class=\"summary\">Web 2.0 Conference</span>:" +
                        "<abbr class=\"dtstart\" title=\"2007-10-05\">October 5</abbr>-" +
                        "<abbr class=\"dtend\" title=\"2007-10-20\">19</abbr>," +
                        " at the <span class=\"location\">Argent Hotel, San Francisco, CA</span>" +
                      "</div>"
                      
    assert_dom_equal(_erbout, expected)
    
  end
  
  def test_another_simple_hcalendar
    _erbout = ''
    
    hcalendar_for(@hcalendar2, {:internal_tag => :abbr}) do |cal|
      _erbout.concat cal.summary(:internal_tag => :h3)
      _erbout.concat cal.description(:internal_tag => :p)
      _erbout.concat("<p>To be held on ") + _erbout.concat(cal.dtstart(:display => "12 March 1998 from 8:30am EST"))
      _erbout.concat("until ") + _erbout.concat(cal.dtend(:display => "9:30am EST")) + _erbout.concat("</p>")
      _erbout.concat("<p>Location: ") + _erbout.concat(cal.location(:internal_tag => :span)) + _erbout.concat("</p>")
      _erbout.concat("<small>Booked by: ") + _erbout.concat(cal.uid(:internal_tag => :span)) + _erbout.concat(" on")
      _erbout.concat(cal.dtstamp(:display => "9 Mar 1998 6:00pm")) + _erbout.concat("</small>")
    end
    
    expected = "<div class=\"vevent\">" +
                        "<h3 class=\"summary\">XYZ Project Review</h3>" +
                        "<p class=\"description\">Project XYZ Review Meeting</p>" +
                        "<p>To be held on <abbr class=\"dtstart\" title=\"1998-03-12T08:30:00+00:00\">12 March 1998 from 8:30am EST</abbr>" +
                        "until <abbr class=\"dtend\" title=\"1998-03-12T09:30:00+00:00\">9:30am EST</abbr></p>" +
                        "<p>Location: <span class=\"location\">1CP Conference Room 4350</span></p>" +
                        "<small>Booked by: <span class=\"uid\">guid-1.host1.com</span> on" + 
                        "<abbr class=\"dtstamp\" title=\"1998-03-09T00:00:00+00:00\">9 Mar 1998 6:00pm</abbr></small>" +
                      "</div>"
                    
    assert_dom_equal(_erbout, expected, "not equal to")
  end
  
  def test_nested_event_in_calendar
    _erbout=''
    
    hcalendar_for(@hcalendar3, :class => :vcalendar) do |cal|
      cal.event_for(:number => 1) do |e|
        _erbout.concat("<div>Posted at: ") + _erbout.concat(e.dtstamp) + _erbout.concat("</div>")
        _erbout.concat("<div>Sequence: ") + _erbout.concat(e.sequence) + _erbout.concat("</div>")
        _erbout.concat("<div>UID: ") + _erbout.concat(e.uid) + _erbout.concat("</div>")
        _erbout.concat("<div>Organized by: ") + _erbout.concat(e.organizer) + _erbout.concat("</div>")
        _erbout.concat("<div>Attending: ") + _erbout.concat(e.attendee) + _erbout.concat("</div>")
        _erbout.concat("<div>Start Time: ") + _erbout.concat(e.dtstart(:internal_tag => :abbr, :display => "March 24, 1997 12:30 UTC")) + _erbout.concat("</div>")
        _erbout.concat("<div>End Time: ") + _erbout.concat(e.dtend(:internal_tag => :abbr, :display => "March 24, 1997, 21:00 UTC")) + _erbout.concat("</div>")
        _erbout.concat e.summary(:internal_tag => :div)
        _erbout.concat e.description(:internal_tag => :div)
        _erbout.concat e.location(:internal_tag => :div)
      end
    end
    
    expected = "<div class=\"vcalendar\">" +
                         "<div class=\"vevent\">" +
                           "<div>Posted at: <span class=\"dtstamp\">1997-03-24T12:00:00+00:00</span></div>" +
                           "<div>Sequence: <span class=\"sequence\">0</span></div>" +
                           "<div>UID: <span class=\"uid\">uid3@host1.com</span></div>" +
                           "<div>Organized by: <span class=\"organizer\">jdoe@host1.com</span></div>" +
                           "<div>Attending: <span class=\"attendee\">jsmith@host1.com</span></div>" +
                           "<div>Start Time: <abbr class=\"dtstart\" title=\"1997-03-24T12:30:00+00:00\">March 24, 1997 12:30 UTC</abbr></div>" +
                           "<div>End Time: <abbr class=\"dtend\" title=\"1997-03-24T21:30:00+00:00\">March 24, 1997, 21:00 UTC</abbr></div>" +
                           "<div class=\"summary\">Calendaring Interoperability Planning Meeting</div>" +
                           "<div class=\"description\">Discuss how we can test c&s interoperability using iCalendar and other IETF standards.</div>" +
                           "<div class=\"location\">LDB Lobby</div>" +
                         "</div>" +
                       "</div>"
                     
    assert_dom_equal(_erbout, expected)

  end
  
end
