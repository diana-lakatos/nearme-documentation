class AttachableService
  def initialize(attachable_class, params)
    @attachable_class = attachable_class
    @params = params
  end

  def get_attachable
    if @params[:file].present?
      create_or_update_attachable
    else
      @attachable_class.find_by(id: @params[:id])
    end
  end

  def valid?
    if @params[:id].present?
      file = @attachable_class.find_by(id: @params[:id])
      file.valid? if file.present?
    else
      @attachable_class.new(@params).valid?
    end
  end

  def create_or_update_attachable
    if @params[:id].present? && @params[:file].present?
      @attachable_class.update @params[:id], @params
    else
      @attachable_class.create @params
    end
  end
end
