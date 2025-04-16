# frozen_string_literal: true

class DocumentsController < ApplicationController
  def index
    @documents = Current.user.documents.order(created_at: :desc)
  end

  def create

  end

  def download
    document = Document.find(params[:id])
    url = document.file.url(
      response_content_disposition: ContentDisposition.attachment(document.file.metadata['filename'])
    )

    redirect_to url, allow_other_host: true
  end
end
