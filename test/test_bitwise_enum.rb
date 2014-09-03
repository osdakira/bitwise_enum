require File.expand_path('test_helper', File.dirname(__FILE__))

class BitwiseEnumTest < BitwiseEnumBaseTest
  def test_admin?
    user = User.new
    assert_equal false, user.admin?
    user.admin!
    assert_equal true, user.admin?
  end

  def test_not_admin?
    user = User.new
    assert_equal true, user.not_admin?
    user.admin!
    assert_equal false, user.not_admin?
  end

  def test_admin_when_woker
    user = User.new
    user.worker!
    assert_equal false, user.admin?
  end

  def test_not_admin!
    user = User.new
    user.admin!
    user.not_admin!
    assert_equal false, user.admin?
  end
  def test_admin_and_woker
    user = User.new
    user.admin!
    user.worker!
    assert_equal true, user.admin?
    assert_equal true, user.worker?
  end

  def test_set_symbol
    user = User.new
    user.role = :admin
    assert_equal true, user.admin?
  end

  def test_set_symbol_twice
    user = User.new
    user.role = :admin
    user.role = :worker
    assert_equal true, user.admin?
    assert_equal true, user.worker?
  end

  def test_get_enum_values
    assert_equal({admin: 1, worker: 2}, User::ROLE)
  end

  def test_get_enum_value
    user = User.new
    user.admin!
    assert_equal ["admin"], user.role
  end

  def test_get_enum_values
    user = User.new
    user.admin!
    user.worker!
    assert_equal ['admin', 'worker'], user.role
  end

  def test_reset_role
    user = User.new
    user.admin!
    user.worker!
    user.reset_role
    assert_equal [], user.role
  end

  def test_admin_scope
    user1 = User.create(role: :admin)
    user2 = User.create(role: :admin)
    user3 = User.create(role: :worker)
    assert_equal [user1, user2], User.admin
  end

  def test_admin_scope
    user1 = User.create(role: :admin)
    user2 = User.create(role: :admin)
    user2.not_admin!
    user3 = User.create(role: :worker)
    user3.admin!
    assert_equal [user1, user3], User.admin
  end

  def test_real_value
    user = User.new
    assert_equal 1, User::ROLE[:admin]
    user.role = User::ROLE[:admin]
    assert_equal true, user.admin?
  end

  def test_invalid_argument
    user = User.new
    assert_raise(ArgumentError) { user.role = :admin_worker }
  end

  def test_invalid_argument_integer
    user = User.new
    assert_equal 0b11, User::ROLE.values.inject(:+)
    assert_raise(ArgumentError) { user.role = 0b111 }
  end
end
