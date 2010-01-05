define :HCalendar do
    
  identifier :vevent

  has :one do
    url :type => :url
    dtstart :type => :datetime
    dtend :type => :datetime
    dtstamp :type => :datetime
  end
   
  has one( *%w( uid version summary location description ) )

end

