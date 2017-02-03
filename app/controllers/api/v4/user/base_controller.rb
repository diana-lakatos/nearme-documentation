# frozen_string_literal: true
module Api
  module V4
    class User
      class BaseController < Api::BaseController
        skip_before_action :require_authorization
      end
    end
  end
end
