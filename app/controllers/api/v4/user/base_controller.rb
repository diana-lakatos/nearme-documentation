# frozen_string_literal: true
module Api
  class V4::User::BaseController < Api::V4::BaseController
    skip_before_action :require_authorization
  end
end
