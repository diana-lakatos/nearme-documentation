# For now, use the same key for dev/stag/prod. If traffic picks up significantly
# or we need better env separation, create another olark account for dev/prod.
OLARK_API_KEY = if Rails.env.production?
  '6600-362-10-7567'
else
  '6600-362-10-7567'
end

