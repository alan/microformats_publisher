define :Adr do
 
  has :one do
    post_office_box :size => 20
    extended_address :size => 100
    street_address :size => 1..100
    locality :size => 50
    region :size => 50
    postal_code :size => 6..20
    country_name :size => 50
  end
  
  has many( :types => { :size => 10,
    :select_from => %w( DOM INTL POSTAL PARCEL HOME WORK ) } )

end
