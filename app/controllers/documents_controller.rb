# frozen_string_literal: true

class DocumentsController < ApplicationController
  def index
    scope = policy_scope(Document).order(created_at: :desc)
    @pagy, @documents = pagy(scope)
  end

  def create
    document = Current.user.documents.new(file: params[:file])
    authorize document

    # expect to always succeed
    document.save!

    redirect_to documents_url
  end

  def destroy
    document = Current.user.documents.find(params[:id])
    authorize document

    document.destroy

    redirect_to documents_url
  end

  def s3_params
    authorize Document

    response = DocumentUploader.presign_response(:cache, request.env)

    self.status = response[0]
    self.headers.merge!(response[1]) # rubocop:disable Style/RedundantSelf
    self.response_body = response[2]
  end

  def download
    document = Current.user.documents.find(params[:id])
    authorize document

    url = document.file.url(
      response_content_disposition: ContentDisposition.attachment(document.file.metadata['filename'])
    )

    redirect_to url, allow_other_host: true
  end
end
