class V1::ProfileController < V1::BaseController

  # These endpoints require authentication
  before_filter :require_authentication

  def show
    render json: current_user
  end


  def update

    if current_user.update_attributes(profile_params)
      render json: current_user
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end


  # Upload the user's avatar
  def upload_avatar

    tempfile = Tempfile.new("avatar")
    tempfile.binmode
    tempfile << request.body.read
    tempfile.rewind

    avatar_params = {
      :filename => "avatar.jpg",
      :type => "image/jpeg",
      :tempfile => tempfile
    }
    user_avatar = ActionDispatch::Http::UploadedFile.new(avatar_params)

    current_user.avatar = user_avatar

    if current_user.save
      render json: current_user
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

  def destroy_avatar
    current_user.remove_avatar!
    render json: current_user
  end

  #
  #
  private

  # Return user attributes we can update
  def profile_params
    json_params.slice("name", "email", "phone")
  end

end
