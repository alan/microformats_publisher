define :HCard do
    
  identifier :vcard
  
  has :one do
    fn :size => 100
    n :type => :model
    geo :type => :uformat
    tz :size => 6
    photo :type => :url
    logo :type => :url
    sound :type => :url
    bday :type => :datetime
    org :type => :uformat  
    url :type => :url
    email :size => 50
  end
  
  has one( *%w( title role klass key mailer uid rev sort_string label ) )

  has :many do
    nicknames :size => 100
    emails :type => :model
    tels :type => :model
    adrs :type => :uformat
  end
    
  has many( :categories, :notes )
  
end