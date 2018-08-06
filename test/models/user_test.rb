require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
				     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name= ""
	assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "    "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
	assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a"*244 + "@example.com"
	assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
	                     first.last@foo.jp alice+bob@baz.cn]
	valid_addresses.each do |valid_address|
	  @user.email = valid_address
	  assert @user.valid?, "#{valid_address.inspect} should be valid"
	end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@exmaple.
	                       foo@bar_baz.com foo@bar+baz.com]
	invalid_addresses.each do |invalid_address|
	  @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
	end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
	duplicate_user.email = @user.email.upcase
	@user.save
	assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
	@user.email = mixed_case_email
	@user.save
	assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
	assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
	assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil diegst" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
	@user.microposts.build(content: "Lorem ipsum")
	@user.save
	assert_difference 'Micropost.count', -1 do
	  @user.destroy
	end
  end

  test "should follow and unfollow a user" do
    haha = users(:haha)
	archer  = users(:archer)
	assert_not haha.following?(archer)
	haha.follow(archer)
	assert haha.following?(archer)
	assert archer.followers.include?(haha)
	haha.unfollow(archer)
	assert_not haha.following?(archer)
  end

  test "feed should have the right posts" do
    haha   = users(:haha)
	archer = users(:archer)
	lana   = users(:lana)
    # 关注的用户发布的微博
	lana.microposts.each do |post_following|
	  assert haha.feed.include?(post_following)
	end
    # 自己的微博
	haha.microposts.each do |post_self|
	  assert haha.feed.include?(post_self)
	end
    # 未关注用户的微博
	archer.microposts.each do |post_unfollowed|
	  assert_not haha.feed.include?(post_unfollowed)
	end
  end
end
