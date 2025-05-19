# frozen_string_literal: true

module Admin
  class ApiTokensController < BaseController
    def index
      load_tokens
    end

    def create
      @api_token = ApiToken.new(api_token_params)
      authorize @api_token

      @api_token.save!

      load_tokens
    end

    private

    def load_tokens
      @api_tokens = policy_scope(ApiToken).preload(:user).order(created_at: :desc)
      @users = policy_scope(User).order(email: :asc)
    end

    def api_token_params
      params.require(:api_token).permit(:user_id)
    end
  end
end
