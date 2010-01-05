define :Tel do
  has many :types => { :size => 10,
    :select_from => %w( PREF WORK HOME VOICE FAX MSG CELL PAGER BBS
                 MODEM CAR ISDN VIDEO ) }
  has one :value => { :type => :string, :length => 30 }
end  