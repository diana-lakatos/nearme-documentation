MIXPANEL_TOKEN = if Rails.env.production?
  '7ffff7057407af5fe5f71701a1ab26b2'
else
  'cc36cc3f9b51f9f476604fa5dd52f76d'
end

# DesksnearMe::Application.config.middleware.use "Mixpanel::Middleware", MIXPANEL_TOKEN, { persist: true }

