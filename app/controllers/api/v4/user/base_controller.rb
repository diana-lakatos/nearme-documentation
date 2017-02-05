# frozen_string_literal: true
module Api
  class V4::User::BaseController < Api::BaseController
    skip_before_action :require_authorization
  end
end
