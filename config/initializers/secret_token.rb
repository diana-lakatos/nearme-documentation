# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
if %w(production staging).include? Rails.env
  fail ArgumentError if ENV['RAILS_SECRET_TOKEN'].blank? || ENV['RAILS_SECRET_KEY_BASE'].blank?
  DesksnearMe::Application.config.secret_token = ENV['RAILS_SECRET_TOKEN']
  DesksnearMe::Application.config.secret_key_base = ENV['RAILS_SECRET_KEY_BASE']
else
  DesksnearMe::Application.config.secret_token = 'l&]{l8=Y>b+f}&5Ku2[`6~jX4)Q6-xx,85&E]~+*?}V&rR91q[QCgxgvgD\PfUhJ.tVzm4znz!Hk?|aazas`c42GAjRItl}BkIa9>\89_S[=Uvm6TE"F4;VFVVcS}{/Y[6p8`Xj}A)%]F6m'
  DesksnearMe::Application.config.secret_key_base = 'g&]{l8=Y>b+f}&5Ku2[`6~jX4)Q6-xx,85&E]~+*?}V&rR91q[QCgxgvgD\PfUhJ.tVzm4znz!Hk?|aazas`c42GAjRItl}BkIa9>\89_S[=Uvm6TE"F4;VFVVcS}{/Y[6p8`Xj}A)%]F6m'
end
