ENV['MICROFORMATS_ROOT'] = File.expand_path( '..', File.dirname(__FILE__) )

structure_path = File.expand_path( 'structures', ENV['MICROFORMATS_ROOT'] )
ENV['STRUCTURE_PATH'] = [ structure_path, ENV['STRUCTURE_PATH'] ].join( ';' )

require 'yaml'
require 'erb'
require 'microformats/blankslate'
require 'microformats/helpers/validator'
require 'microformats/inflect'
require 'microformats/ufenumerable'
require 'microformats/appenders'
require 'microformats/defaults'

# require 'breakpoint'
require 'microformats/structures'

require 'microformats/helpers/individual_helpers'
require 'microformats/helpers/microformat_helper'
require 'microformats/helpers/sub_formats_helper'

# Construct the the Microformats::Base class that all the
# microformat structure definitions inherit from. Each microformat definition
# has a number of has_one or has_many statements that define the attributes
# that will be used to create the migrations and models.
#
# Additional microformats can be defined in the structures directory.
# Each microformat defined in the structures directory is loaded into the
# Microformats::Structures namespace and can be accessed with the
# get(:ufname) method.

module Rails
  module Generator
    class Base
      include Microformats
    end
  end
end

#Rails::Generator::Base.send :include, Microformats
#ActionView::Base.send :include, Microformat::ViewHelpers::MicroformatCreator
ActionView::Base.send :include, Microformat::Helpers::ViewHelpers
