# frozen_string_literal: true

class UserFilesController < ApplicationController
  def index
    scope = policy_scope(UserFile).order(created_at: :desc)
    @pagy, @user_files = pagy(scope)
  end

  def create
    user_file = Current.user.user_files.new(attachment: params[:file])
    authorize user_file

    # expect to always succeed
    user_file.save!

    redirect_to files_url
  end

  def destroy
    user_file = Current.user.user_files.find(params[:id])
    authorize user_file

    user_file.destroy

    redirect_to files_url
  end

  def s3_params
    authorize UserFile

    response = UserFileUploader.presign_response(:cache, request.env)

    self.status = response[0]
    self.headers.merge!(response[1]) # rubocop:disable Style/RedundantSelf
    self.response_body = response[2]
  end

  def download
    user_file = Current.user.user_files.find(params[:id])
    authorize user_file

    url = user_file.attachment.url(
      response_content_disposition: ContentDisposition.attachment(user_file.attachment.original_filename)
    )

    redirect_to url, allow_other_host: true
  end
end
