require File.dirname(__FILE__) + '/test_helper'

class MicroformatsTest < Test::Unit::TestCase

  @@real_structures = %w(HCard HReview HCalendar Adr Email Geo Item N Org Tel)
  @@structures = %w( parent childless_child procreating_child )
  
  include Microformats

  # test defined structures load and have their names initialised
  def test_structures_accessor_names_inflected
    @@structures.each do |structure|
      assert struct_class = Structure.get(structure),
        "Failed to load structure: #{structure}"
      assert_equal struct_class.class_name, structure,
        "Invalid class_name for: #{structure}"
      assert_equal struct_class.table_name, structure.underscore.pluralize,
        "Invalid table_name for: #{structure}"
      assert_equal struct_class.plural_name, structure.underscore.pluralize,
        "Invalid plural_name for: #{structure}"
      assert_equal struct_class.singular_name, structure.underscore,
        "Invalid singular_name for: #{structure}"
    end
    assert_equal @@structures.sort, Structure.structures.sort,
      "Unexpected structure names."
  end

  # test the different forms of structure name all return the right structure
  # and invalid names fail
  def test_structures_method_struct_get
    structures = ['Microformats::Structures::HCard', :h_card, "HCard", "h_card"]
    structures.each do |structure|
      assert struct_class = Structure.get(structure),
        "Failed to load structure: #{structure} #{structure.class}"
      assert_equal struct_class.class_name.camelcase.downcase,
        structure.to_s.split('::').pop.camelcase.downcase,
        "Invalid class_name for: #{structure}"
    end
    assert_raise(NameError, "No exception raise for undefined structure.") do
      Structure.get("fail")
    end
  end

  # test we can instantiate all the structures with the load_all method
  def test_structures_method_load_all
    assert Microformats::Structures.load_all, "Failed to load all structures"
    assert_equal Microformats::Structures.constants.sort,
      @@constants.sort, "Unexpected structure names."
  end

  # test that all sub structure names are returned and there are no duplicates
  def test_base_method_every_sub_structure
    assert structure = Structure.get(:super)
    sub_structures = %w(ManySub1 ManySub1Sub1 ManySub1Sub1Sub1 ManySub1Sub2 ManySub2 OneSub1 OneSub1Sub1 OneSub1Sub1Sub1 OneSub1Sub2 OneSub2)
    structure.every_sub_structure do |struct|
      assert sub_structures.delete(struct)
    end
    assert_equal sub_structures, []
  end

  # test we can get and set models and their validations
  def test_model_model_get
    models = %w(Model1 Model2 Model3 Model4)
    values = [%w(one1 many1 belong1 att1 ser1), %w(one2 many2 belong2 att2 ser2), %w(one3 many3 belong3 att3 ser3)]
    models.each do |model_name|
      assert model = Microformats::Models.model_get(model_name), "Failed to get new model #{model}"
      assert_equal model.name, "Microformats::Models::#{model_name}", "Name for model #{model} not set correctly"
      # setup the initial values and test they are what we expect
      assert model.have_one << values[0][0], "Failed to append #{values[0][0]} to #{model.name}.have_one"
      assert model.have_many << values[0][1], "Failed to append #{values[0][1]} to #{model.name}.have_many"
      assert model.belong_to << values[0][2], "Failed to append #{values[0][2]} to #{model.name}.belong_to"
      assert model.validations << values[0][3], "Failed to append #{values[0][3]} to #{model.name}.validations"
      assert model.serialize << values[0][4], "Failed to append #{values[0][4]} to #{model.name}.serialize"
      # check they are there
      assert_equal model.have_one[0], values[0][0], "Expected #{values[0][0]} but was #{model.have_one[0]}"
      assert_equal model.have_many[0], values[0][1], "Expected #{values[0][1]} but was #{model.have_many[0]}"
      assert_equal model.belong_to[0], values[0][2], "Expected #{values[0][2]} but was #{model.belong_to[0]}"
      assert_equal model.validations[0], values[0][3], "Expected #{values[0][3]} but was #{model.validations[0]}"
      assert_equal model.serialize[0], values[0][4], "Expected #{values[0][4]} but was #{model.serialize[0]}"
      # append a 2nd value
      assert model.have_one << values[1][0], "Failed to append #{values[1][0]} to #{model.name}.have_one"
      assert model.have_many << values[1][1], "Failed to append #{values[1][1]} to #{model.name}.have_many"
      assert model.belong_to << values[1][2], "Failed to append #{values[1][2]} to #{model.name}.belong_to"
      assert model.validations << values[1][3], "Failed to append #{values[1][3]} to #{model.name}.validations"
      assert model.serialize << values[1][4], "Failed to append #{values[1][4]} to #{model.name}.serialize"
      # check it is there
      assert_equal model.have_one[1], values[1][0], "Expected #{values[1][0]} but was #{model.have_one}"
      assert_equal model.have_many[1], values[1][1], "Expected #{values[1][1]} but was #{model.have_many}"
      assert_equal model.belong_to[1], values[1][2], "Expected #{values[1][2]} but was #{model.belong_to}"
      assert_equal model.validations[1], values[1][3], "Expected #{values[1][3]} but was #{model.validations}"
      assert_equal model.serialize[1], values[1][4], "Expected #{values[1][4]} but was #{model.serialize}"
      # try to add a duplicate
      assert_nil model.have_one << values[1][0], "Should not be able to append #{values[1][0]} to #{model.name}.have_one"
      assert_nil model.have_many << values[1][1], "Should not be able to append #{values[1][1]} to #{model.name}.have_many"
      assert_nil model.belong_to << values[1][2], "Should not be able to append #{values[1][2]} to #{model.name}.belong_to"
      assert_nil model.validations << values[1][3], "Should not be able to append #{values[1][3]} to #{model.name}.validations"
      assert_nil model.serialize << values[1][4], "Should not be able to append #{values[1][4]} to #{model.name}.serialize"
      # check the orginals are still valid
      assert_equal model.have_one[0], values[0][0], "Expected #{values[0][0]} but was #{model.have_one[0]}"
      assert_equal model.have_many[0], values[0][1], "Expected #{values[0][1]} but was #{model.have_many[0]}"
      assert_equal model.belong_to[0], values[0][2], "Expected #{values[0][2]} but was #{model.belong_to[0]}"
      assert_equal model.validations[0], values[0][3], "Expected #{values[0][3]} but was #{model.validations[0]}"
      assert_equal model.serialize[0], values[0][4], "Expected #{values[0][4]} but was #{model.serialize[0]}"
      # re-define the whole shooting match
#      model.have_one, model.have_many, model.belong_to, model.validations = *values[2]
#      assert_equal model.have_one[0], values[2][0], "Expected #{values[2][0]} but was #{model.have_one[0]}"
#      assert_equal model.have_many[0], values[2][1], "Expected #{values[2][1]} but was #{model.have_many[0]}"
#      assert_equal model.belong_to[0], values[2][2], "Expected #{values[2][2]} but was #{model.belong_to[0]}"
#      assert_equal model.validations[0], values[2][3], "Expected #{values[2][3]} but was #{model.validations[0]}"
      # and is this the only attribute
#      assert_equal model.have_one.length, 1, "Expected 1 value but got #{model.have_one}"
#      assert_equal model.have_many.length, 1, "Expected 1 value but got #{model.have_many}"
#      assert_equal model.belong_to.length, 1, "Expected 1 value but got #{model.belong_to}"
#      assert_equal model.validations.length, 1, "Expected 1 value but got #{model.validations}"
    end
    # test the enumerator
  end
end
