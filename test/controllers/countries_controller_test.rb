require 'test_helper'

class CountriesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "the truth" do
    assert true
  end

  setup do
    @user = create(:user)
    @user.add_role :admin
    sign_in @user
  end

  def teardown
    User.delete_all
  end

  test "index should render correct template and layout" do
    get :index
    assert_template :index
    assert_template layout: "layouts/application"
  end

  test "should create country and go to its show page" do
    assert_difference('Country.count') do
      post :create, country: {name: 'Albania'}
    end
    assert_redirected_to country_path(assigns(:country))
  end

  test "should not create country without its name" do
    assert_no_difference('Country.count') do
      post :create, country: {name: nil}
    end
  end

  test "should not create a duplicate country associated with same organization" do
    assert_difference('Country.count', 1) do
      2.times {
        post :create, country: {name: 'Albania'}
      }
    end
  end

  test "should delete country along with all sites under that country" do
    country = Country.create!({name: 'Azerbaijan', organization_id: @user.organization.id })
    site = Site.create!({country_id: country.id, name:'Leh'})

    assert_difference('Country.count',-1) do
      puts Country.count
      delete :destroy, id: country.id
      assert_response :redirect
      puts Country.count
    end

    assert_nil Country.find_by_id(country.id)
    assert_nil Site.find_by_country_id(country.id)
    assert_nil Site.find_by_id(site.id)
  end

end
