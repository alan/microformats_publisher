define :Email do
  
  has :one do 
    etype :size => 10, :select_from => %w( AOL AppleLink ATTMail CIS eWorld INTERNET
                IBMMail MCIMail POWERSHARE PRODIGY TLX X400 )
    value :etype => :email
  end
  
end  

