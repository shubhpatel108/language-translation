require "test_helper"

class API::ArticlesControllerTest < ActionController::TestCase
  tests API::ArticlesController

  def setup
    @request.host = "localshot:3000"

    @user = create(:user)
    @user.add_role :admin
    @language = create(:language, name: 'Chuukese')
    @category = create(:category, name: 'Places')
  end

  def teardown
    User.delete_all
    Article.delete_all
    Language.delete_all
    Category.delete_all
  end

  def upload_image(image_name)
    Rack::Test::UploadedFile.new(
        File.join(Rails.root, 'test', 'support', 'picture', image_name)
      )
  end

  def create_article(image_name = "logo.jpg")
    create(:article,
                 {
                    english: "Cat",
                    phonetic: "Tac",
                    language_id: @language.id,
                    category_id: @category.id,
                    picture: upload_image(image_name)
                 })
  end

  describe "Get #index" do
    describe "when all article renders" do
      before(:each) do
        3.times {
          create_article
        }
      end

      it "return 3 records" do
        get :index, {format: :json, auth_token: @user.authentication_token }

        assert_equal 200, response.status
        assert_equal 3, json_response["articles"].length
      end
    end
  end

  describe "Get #show" do
    describe "when fetch one article" do
      before(:each) do
        @article = create_article
      end

      it "should return article attributes" do
        get :show, {format: :json, auth_token: @user.authentication_token, id: @article.id }

        article = json_response["article"]

        assert_equal 200, response.status

        assert_equal "Cat",   article["english"]
        assert_equal "Tac",   article["phonetic"]
      end
    end
  end

  describe "POST #create" do
    describe "when a article is successfully created" do
      before(:each) do
        attributes = attributes_for(:article,
                                    {
                                        english: 'Cat',
                                        phonetic: "Tac",
                                        language_id: @language.id,
                                        picture: Rack::Test::UploadedFile.new(File.join(Rails.root, 'test', 'support', 'picture', 'logo.jpg'))
                                    })

        post :create, { format: :json, auth_token: @user.authentication_token, article: attributes }
      end

      it "renders json response for the record just created" do
        article = json_response["article"]

        assert_equal 201, response.status

        assert_equal "Cat",   article["english"]
        assert_equal "Tac",   article["phonetic"]
      end
    end

    describe "when is not created" do
      before(:each) do
        attributes = {english: "Home"}

        post :create, { format: :json, auth_token: @user.authentication_token, article: attributes }
      end

      it "render an error json for article" do
        error_response = json_response

        assert_equal 422, response.status

        assert          error_response["errors"]
        assert_includes error_response["errors"]["picture"], "Picture can't be blank"
      end
    end
  end

  describe "PUT/PATCH #update" do
    before(:each) do
      @article = create_article
    end

    describe "when is successfully updated" do
      before(:each) do
        put :update, { format: :json, auth_token: @user.authentication_token, id: @article.id, article: { english: "Cat - updated" }}
      end

      it "renders json response for the updated article" do

        assert_equal 200, response.status
        assert_equal "Cat - updated", json_response["article"]["english"]
      end
    end
  end

  describe "DELETE #destroy" do
    describe "delete" do
      before(:each) do
        @article = create_article
      end

      it "render josn response for the deleted object" do
        delete :destroy, { format: :json, auth_token: @user.authentication_token, id: @article.id }

        article = json_response
        assert_equal @article.id, article["article"]["id"]
        assert_equal true,        article["article"]["deleted"]
      end
    end
  end

end
