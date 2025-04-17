# frozen_string_literal: true

class DocumentsController < ApplicationController
  def index
    @documents = Current.user.documents.order(created_at: :desc)
  end

  def create
    # expect to always succeed
    Current.user.documents.create!(file: params[:file])

    redirect_to documents_path
  end

  def destroy
    document = Document.find(params[:id])
    document.destroy

    redirect_to documents_path
  end

  def s3_params
    response = DocumentUploader.presign_response(:cache, request.env)

    self.status = response[0]
    self.headers.merge!(response[1]) # rubocop:disable Style/RedundantSelf
    self.response_body = response[2]
  end

  def download
    document = Document.find(params[:id])
    url = document.file.url(
      response_content_disposition: ContentDisposition.attachment(document.file.metadata['filename'])
    )

    redirect_to url, allow_other_host: true
  end
end
