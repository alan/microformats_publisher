require File.dirname(__FILE__) + '/test_helper'

class MicroformatsTest < Test::Unit::TestCase

  structure_fixtures :structures
  
  @@real_structures = %w(HCard HReview HCalendar Adr Email Geo Item N Org Tel)
  @@structures = %w( parent childless_child procreating_child )
  
  include Microformats

  # test defined structures load and have their names initialised
  def test_structure_names_inflected
    @@structures.each do |structure|
      assert struct_class = Structure.get(structure),
        "Failed to load structure: #{structure}"
      assert_equal struct_class.class_name, structure.camelcase,
        "Invalid class_name for: #{structure}"
      assert_equal struct_class.table_name, structure.camelcase.underscore.pluralize,
        "Invalid table_name for: #{structure}"
      assert_equal struct_class.plural_name, structure.underscore.pluralize,
        "Invalid plural_name for: #{structure}"
      assert_equal struct_class.singular_name, structure.camelcase.underscore,
        "Invalid singular_name for: #{structure}"
    end
  end

  # test the different forms of structure name all return the right structure
  # and invalid names fail
  def test_structure_method_get
    structures = [:childless_child, :ChildlessChild, "Childless_child", "childless_child"]
    structures.each do |structure|
      assert struct_class = Structure.get(structure),
        "Failed to load structure: #{structure} #{structure.class}"
      assert_equal struct_class.class_name.downcase,
        structure.to_s.camelcase.downcase,
        "Invalid class_name for: #{structure}"
    end
    assert_raise(NameError, "No exception raise for undefined structure.") do
      Structure.get("fail")
    end
  end


  # test that all sub structure names are returned and there are no duplicates
  def test_base_method_each_sub_structure
    assert structure = Structure.get(:parent)
    sub_structures = %w(childless_child procreating_child)
    structure.each_sub_structure do |struct|
      assert sub_structures.delete(struct.to_s)
    end
    assert_equal sub_structures, []
  end

end
