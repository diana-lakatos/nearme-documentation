class CustomModelTypeDrop < BaseDrop

  delegate :name, to: :source

  def initialize(source)
    @source = source
  end

end