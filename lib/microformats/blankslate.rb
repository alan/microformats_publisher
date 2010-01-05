module Microformats
  class BlankSlate
    keep = %w( class method extend send instance_eval instance_variable_set instance_variable_get
               instance_of? respond_to? breakpoint to_s inspect methods instance_variables)
    instance_methods.sort.each do |m|
      undef_method(m) unless ( m =~ /^__/ || keep.include?(m) )
    end
  end  # BlankSlate
end
