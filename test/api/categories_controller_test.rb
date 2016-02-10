require "test_helper"

class API::CategoriesControllerTest < ActionController::TestCase
  tests API::CategoriesController

  def setup
    @request.host = "localshot:3000"

    @user = create(:user)
    @user.add_role :admin
  end

  def teardown
    User.delete_all
    Category.delete_all
  end

  def create_category(name = "Places")
    create(:category, { name: name })
  end

  describe "Get #index" do
    describe "when all category renders" do
      before(:each) do
        3.times do |index|
          create_category("Category#{index}")
        end
      end

      it "return 3 records" do
        get :index, {format: :json, auth_token: @user.authentication_token }

        assert_equal 200, response.status
        assert_equal 3, json_response["categories"].length
      end
    end
  end

  describe "Get #show" do
    describe "when fetch one category" do
      before(:each) do
        @category = create_category
      end

      it "should return category attributes" do
        get :show, {format: :json, auth_token: @user.authentication_token, id: @category.id }

        category = json_response["category"]

        assert_equal 200, response.status
        assert_equal "Places",   category["name"]
      end
    end
  end

  describe "POST #create" do
    describe "when a category is successfully created" do
      before(:each) do
        attributes = attributes_for(:category, name: "Places")

        post :create, { format: :json, auth_token: @user.authentication_token, category: attributes }
      end

      it "renders json response for the record just created" do
        category = json_response["category"]

        assert_equal 201, response.status

        assert_equal "Places",   category["name"]
      end
    end

    describe "when is not created" do
      before(:each) do
        attributes = {name: ""}

        post :create, { format: :json, auth_token: @user.authentication_token, category: attributes }
      end

      it "render an error json for category" do
        error_response = json_response

        assert_equal 422, response.status

        assert          error_response["errors"]
        assert_includes error_response["errors"]["name"], "Name can't be blank"
      end
    end
  end

  describe "PUT/PATCH #update" do
    before(:each) do
      @category = create_category
    end

    describe "when is successfully updated" do
      before(:each) do
        put :update, { format: :json, auth_token: @user.authentication_token, id: @category.id, category: { name: "Places-updated" }}
      end

      it "renders json response for the updated category" do

        assert_equal 200, response.status
        assert_equal "Places-updated", json_response["category"]["name"]
      end
    end

    describe "when is not updated" do
      before(:each) do
        put :update, { format: :json, auth_token: @user.authentication_token, id: @category.id, category: { name: "" }}
      end

      it "render an error json for the resource" do
        category = json_response

        assert_equal 422, response.status
        assert            category["errors"]
        assert_includes   category["errors"]["name"], "Name can't be blank"
      end
    end
  end

  describe "DELETE #destroy" do
    describe "delete" do
      before(:each) do
        @category = create_category
      end

      it "render josn response for the deleted object" do
        delete :destroy, { format: :json, auth_token: @user.authentication_token, id: @category.id }

        category = json_response
        assert_equal @category.id, category["category"]["id"]
        assert_equal true,        category["category"]["deleted"]
      end
    end
  end

end
