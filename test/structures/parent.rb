define :Parent do
  
  has one do
    childless_child :type => :uformat
    procreating_child :type => :uformat
  end
  
end
