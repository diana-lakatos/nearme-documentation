require 'liquid_view'
require 'liquid_blank_file_system'

ActionView::Template.register_template_handler :liquid, LiquidView
