load 'microformats.rb'
include Microformats

x = Structures.get :h_card
puts Models::HCard.all_sub_models

include Microformats
x = Structure.get :testie2

instance_eval(File.read(file_name)) if File.file? file_name