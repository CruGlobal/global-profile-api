# To include some tests for global_registry_methods automatically, copy this file to 
# spec/support/shared_examples_for_global_registry_models.rb in the enclosing app then 
# add include_examples "global_registry_methods" to the enclosing spec
#
# for example:
#
# RSpec.describe Address, :type => :model do
#   include_examples "global_registry_methods"
# end
#
# there should be some lines in your spec_helper.rb like this:
#
#   # Requires supporting ruby files with custom matchers and macros, etc,
#   # in spec/support/ and its subdirectories.
#   Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
#
# that will automatically include the file once it's copied to spec/support
#
shared_examples "global_registry_methods" do
  context "self.skip_fields_for_gr" do
    it "should run" do
      expect(described_class.skip_fields_for_gr.class).to eq(Array), "Expected #{described_class}.skip_fields_for_gr to return an Array"
      expect(described_class.skip_fields_for_gr.collect(&:class).uniq).to eq([String]), "Expected #{described_class}.skip_fields_for_gr to return an Array of Strings"
      expect(described_class.skip_fields_for_gr.uniq).to eq(described_class.skip_fields_for_gr), "Expected #{described_class}.skip_fields_for_gr to return an Array with no duplicates (#{described_class.skip_fields_for_gr.find_all{ |c| described_class.skip_fields_for_gr.count(c) > 1 }.uniq} are all in the array at least twice)"
      expect(described_class.skip_fields_for_gr - described_class.column_names - described_class.attribute_aliases.keys).to be_empty, "Expected #{described_class}.skip_fields_for_gr to return an Array of Strings where each string is a column or attribute alias (#{described_class.skip_fields_for_gr - described_class.column_names - described_class.attribute_aliases.keys} are not columns or attribute aliases)"
    end
  end
end
