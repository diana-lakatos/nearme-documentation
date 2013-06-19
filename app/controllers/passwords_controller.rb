class PasswordsController < Devise::PasswordsController
  after_filter :rename_flash_messages, only: [:create]


  def after_sending_reset_password_instructions_path_for(resource_name)
    root_path
  end

end
