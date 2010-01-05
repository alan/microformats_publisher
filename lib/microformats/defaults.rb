module Microformats

  module Defaults

    @@pseudo_types = {
      :url => { :type => :string, :size => 10..255, 
        :format => "/^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix"
      },
      :email => { :type => :string, :size => 3..255, 
        :format => "/^[A-Za-z\d.+-]+@[A-Za-z\d.+-]+\.[A-Za-z\d.+-]+/"
      }
    }

  end
  
end
