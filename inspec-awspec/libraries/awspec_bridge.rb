require 'awspec'

# TODO: bridge the auth systems so that `inspec aws://region/profile` will communicate with awsecrets (used by awspec)

# AWSSPEC resources do not get declared as InSpec resources
require 'byebug'

# See https://github.com/k1LoW/awspec/blob/master/lib/awspec/helper/type.rb
# awspec maintains a list of snakecase resource names in this const
#   Awspec::Helper::Type::TYPES
# and it converts those to class names like this
# Object.const_get("Awspec::Type::#{type.camelize}")
#  (note that awspec extends String with `camelize`)

Awspec::Helper::Type::TYPES.each do |awspec_type_name|
  awspec_klass = Object.const_get("Awspec::Type::#{awspec_type_name.camelize}")
  # Define an Inspec custom resource class for each awspec class
  Class.new(Inspec.resource(1)) do
    name awspec_type_name
    supports platform: 'aws'

    # So, we don't have multiple inheritance, but we want all calls against
    # instances of this class to actually hit the code in the awspec class.
    # (including the constructor)
    # We'd like to just include the awspec_klass, but it is a Class, not a Module.
    # So, how about method_missing? (Awspec::Type::Base provides a method_missing, too)

    def initialize(*args)
      @awspec_obj = awspec_klass.new(*args)
    end

    def method_missing(method_name, *args, &block)
      awspec_obj.send(method_name, args, block)
    end

  end
end

1