define :Geo do

  has :one do
    latitude :type => :float, :null => false
    longitude :type => :float, :null => false
  end  

end