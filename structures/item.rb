 define :Item do
   
  has :one do
    fn
    h_card :type => :uformat
    h_calendar :type => :uformat
  end
  
  has :many do  
    urls :type => :url
    photos :type => :url
  end  
end