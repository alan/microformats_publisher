define :HReview do
  
  has :one do
    type  :select_from => %w( product business event person place website url )
    dtreviewed :type => :datetime
    permalink :type => :url
    h_card :type => :uformat
  end

  has :many do
    tags  
    ratings :type => :integer, 
      :select_from => { 1 => :worst, 2 => 2, 3 => 3, 4 => 4, 5 => :best }
  end  
    
  has one( :version,  :summary, :item, :description )
  
end  