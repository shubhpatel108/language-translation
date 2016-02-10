require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  tests CategoriesController

  include Devise::TestHelpers

  setup do
    @user = create(:user)
    @user.add_role :admin
    sign_in @user
  end

  def teardown
    User.delete_all
    Category.delete_all
  end

  test "index should render correct template and layouts" do
    get :index

    assert_template :index
    assert_template layout: "layouts/application"
  end

  test "should create one category and rediect to the #show" do
    post :create, category: {name: "Books"}

    assert_equal "Books", assigns(:category).name
    assert_equal "Category successfully created.", flash[:notice]
    assert_redirected_to edit_category_path(assigns(:category))
  end

  test "should not create a category without name" do
    post :create, category: {name: ""}

    assert_equal "Sorry, failed to create category due to errors.", flash[:error]
    assert_template(:new)
  end

  test "should not create a duplicate category with same name" do
    assert_difference('Category.count', 1) do
      2.times {
        post :create, category: {name: "Books"}
      }
    end

    assert_equal "Sorry, failed to create category due to errors.", flash[:error]
    assert_template(:new)
  end

  test "should update category name" do
    category = create(:category, name: "Books")

    put :update, {id: category.id, category: {name: "Cars"} }

    assert_equal "Cars", assigns(:category).name
    assert_equal "Category successfully updated.", flash[:notice]
    assert_redirected_to edit_category_path(assigns(:category))
  end

  test "should not update without category name" do
    category = create(:category, name: "Books")

    put :update, {id: category.id, category: {name: ""} }

    assert_empty assigns(:category).name
    assert_equal "Sorry, failed to update category due to errors.", flash[:error]
    assert_template(:edit)
  end

  test "should delete category" do
    category = create(:category, name: "Books")

    delete :destroy, {id: category.id}

    assert_equal "Category has been deleted.", flash[:notice]
    assert_redirected_to categories_path
  end

end
