require "test_helper"

class API::LanguagesControllerTest < ActionController::TestCase
  tests API::LanguagesController

  def setup
    @request.host = "localshot:3000"

    @user = create(:user)
    @user.add_role :admin
  end

  def teardown
    User.delete_all
    Language.delete_all
  end

  def create_language(name = "Chuukese")
    create(:language, { name: name })
  end

  describe "Get #index" do
    describe "when all language renders" do
      before(:each) do
        3.times do |index|
          create_language("Chuukese#{index}")
        end
      end

      it "return 3 records" do
        get :index, {format: :json, auth_token: @user.authentication_token }

        assert_equal 200, response.status
        assert_equal 3, json_response["languages"].length
      end
    end
  end

  describe "Get #show" do
    describe "when fetch one language" do
      before(:each) do
        @language = create_language
      end

      it "should return language attributes" do
        get :show, {format: :json, auth_token: @user.authentication_token, id: @language.id }

        language = json_response["language"]

        assert_equal 200, response.status
        assert_equal "Chuukese",   language["name"]
      end
    end
  end

  describe "POST #create" do
    describe "when a language is successfully created" do
      before(:each) do
        attributes = attributes_for(:language, name: "Chuukese")

        post :create, { format: :json, auth_token: @user.authentication_token, language: attributes }
      end

      it "renders json response for the record just created" do
        language = json_response["language"]

        assert_equal 201, response.status

        assert_equal "Chuukese",   language["name"]
      end
    end

    describe "when is not created" do
      before(:each) do
        attributes = {name: ""}

        post :create, { format: :json, auth_token: @user.authentication_token, language: attributes }
      end

      it "render an error json for language" do
        error_response = json_response

        assert_equal 422, response.status

        assert          error_response["errors"]
        assert_includes error_response["errors"]["name"], "Name can't be blank"
      end
    end
  end

  describe "PUT/PATCH #update" do
    before(:each) do
      @language = create_language
    end

    describe "when is successfully updated" do
      before(:each) do
        put :update, { format: :json, auth_token: @user.authentication_token, id: @language.id, language: { name: "English" }}
      end

      it "renders json response for the updated language" do

        assert_equal 200, response.status
        assert_equal "English", json_response["language"]["name"]
      end
    end

    describe "when is not updated" do
      before(:each) do
        put :update, { format: :json, auth_token: @user.authentication_token, id: @language.id, language: { name: "" }}
      end

      it "render an error json for the resource" do
        language = json_response

        assert_equal 422, response.status
        assert            language["errors"]
        assert_includes   language["errors"]["name"], "Name can't be blank"
      end
    end
  end

  describe "DELETE #destroy" do
    describe "delete" do
      before(:each) do
        @language = create_language("Chuukese1")
      end

      it "render josn response for the deleted object" do
        delete :destroy, { format: :json, auth_token: @user.authentication_token, id: @language.id }

        language = json_response
        assert_equal @language.id, language["language"]["id"]
        assert_equal true,        language["language"]["deleted"]
      end
    end
  end

end
