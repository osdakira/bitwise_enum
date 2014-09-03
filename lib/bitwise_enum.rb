require 'active_record/base'
require "bitwise_enum/version"

# Clone from `ActiveRecord::Enum`.
#
# Declare an bitwise enum attribute where the values map to integers in the database, but can be queried by name. Example:
#
#   class User < ActiveRecord::Base
#     bitwise_enum role: [ :admin, :worker ]
#   end
#
#   # user.update! role: "admin"
#   user.admin!
#   user.admin? # => true
#   user.role  # => "['admin']"
#
#   # user.update! role: "worker"
#   user.worker!
#   user.worker? # => true
#   user.role    # => "['worker']"
#
#   user.admin!
#   user.admin? # => true
#   user.worker!
#   user.worker? # => true
#   user.role    # => "['admin', 'worker']"
#
#   user.admin!
#   user.admin? # => true
#   user.not_admin!
#   user.admin? # => false
#
#   # user.update! role: 1
#   user.role = :admin
#   user.role # => ['admin']
#
#   user.admin! # => ['admin']
#   user.reset_role # => nil
#   user.role = []
#
# Finally, it's also possible to explicitly map the relation between attribute and
# database integer with a +Hash+:
#
#   class User < ActiveRecord::Base
#     enum role: { admin: 1 << 0, worker: 1 << 1 }
#   end
#
# Note that when an +Array+ is used, the implicit mapping from the values to database
# integers is derived from the order the values appear in the array. In the example,
# <tt>:admin</tt> is mapped to +0b1+ as it's the first element, and <tt>:worker</tt>
# is mapped to +0b10+. In general, the +i+-th element is mapped to <tt>1 << i-1</tt> in the
# database.
#
# Therefore, once a value is added to the enum array, its position in the array must
# be maintained, and new values should only be added to the end of the array. To
# remove unused values, the explicit +Hash+ syntax should be used.
#
# In rare circumstances you might need to access the mapping directly.
# The mappings are exposed through a constant with the attributes name:
#
#   User::ROLE # => { "admin" => 1, "worker" => 2 }
#
# Use that constant when you need to know the ordinal value of an enum:
#
#   User.where("role <> ?", User::ROLE[:worker])
#
# A scope call bitwise 'SELECT' sql
#

module BitwiseEnum
  def bitwise_enum(definitions)
    klass = self
    definitions.each do |name, values|
      # DIRECTION = { }
      bitwise_enum_values = _bitwise_enum_methods_module.const_set name.to_s.upcase, ActiveSupport::HashWithIndifferentAccess.new
      name        = name.to_sym

      _bitwise_enum_methods_module.module_eval do
        # def role=(value) self[:role] = ROLE[value] end
        define_method("#{name}=") { |value|
          if bitwise_enum_values.has_key?(value)
            bit = bitwise_enum_values[value]
            self[name] = self[name].nil? ? bit : (self[name] |= bit)
          elsif value.is_a?(Integer) && value <= bitwise_enum_values.values.inject(:+)
            self[name] = value
          else
            raise ArgumentError, "'#{value}' is not a valid #{name}"
          end
        }

        # def role() ROLE.select{|_, bit| !(self[:role] & bit).zero?}.keys end
        define_method(name) {
          return [] if self[name].nil?
          bitwise_enum_values.select{|k, bit| !(self[name] & bit).zero?}.keys
        }

        # def reset_role(); self[:role] = nil; end
        define_method("reset_#{name}"){ self[name] = nil }

        # bitwise index
        pairs = values.respond_to?(:each_pair) ? values.each_pair : values.map.with_index{|value, index| [value, 1 << index]}
        pairs.each do |value, bit|
          bitwise_enum_values[value] = bit

          # scope :admin, -> { where("role & 1 = 0") }
          # FIXME use arel
          klass.scope value, -> { klass.where("#{name} & #{bit} = #{bit}") }

          # def admin?() role == 1 end
          define_method("#{value}?") do
            self[name].nil? ? false : !(self[name] & bit).zero?
          end

          define_method("not_#{value}?") do
            self[name].nil? ? true : (self[name] & bit).zero?
          end

          # def admin! update! role: :admin end
          define_method("#{value}!") do
            update_attributes! name => self[name].nil? ? bit : (self[name] |= bit)
          end

          define_method("not_#{value}!") do
            update_attributes! name => self[name] &= ~bit if self[name]
          end
        end
      end
    end
  end

  private
    def _bitwise_enum_methods_module
      @_bitwise_enum_methods_module ||= begin
        mod = Module.new
        include mod
        mod
      end
    end
end

# Extend ActiveRecord's functionality
ActiveRecord::Base.send :extend, BitwiseEnum
