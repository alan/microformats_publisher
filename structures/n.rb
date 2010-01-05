define :N do
  has one :family_name, :given_name, :additional_name
  has many :honorific_prefixes, :honorific_suffixes
end

