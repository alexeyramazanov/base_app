# frozen_string_literal: true

class HomeController < ApplicationController
  allow_only_unauthenticated_access

  def show
  end
end
