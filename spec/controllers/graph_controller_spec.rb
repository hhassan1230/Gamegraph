require 'rails_helper'

RSpec.describe GraphController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #game" do
    it "returns http success" do
      get :game
      expect(response).to have_http_status(:success)
    end
  end

end
