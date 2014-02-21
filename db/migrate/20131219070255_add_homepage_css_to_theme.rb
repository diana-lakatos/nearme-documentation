class AddHomepageCssToTheme < ActiveRecord::Migration

  class Instance < ActiveRecord::Base
  end

  class Theme < ActiveRecord::Base
  end

  def up
    add_column :themes, :homepage_css, :text

    dnm_instance = Instance.find(1)
    dnm_theme = Theme.where('owner_id = ? AND owner_type = ?', dnm_instance.try(:id), 'Instance').first

    if dnm_instance && dnm_theme
      styles = <<-CSS
section.how-it-works {
  text-align: center;
}
section.how-it-works .row-fluid {
  padding: 30px 0 0;
  margin: 0;
}
section.how-it-works h1 {
  font-size: 3.33333em;
  line-height: 1.16667em;
  margin: 10px 0 0;
  color: #3c3c3c;
  font-family: "Futura-demi", sans-serif;
}
@media (max-width: 480px) {
  section.how-it-works h1 {
    font-size: 2.33333em;
    line-height: 1.33333em;
  }
}
section.how-it-works h2 {
  font-size: 1.66667em;
  line-height: 1.4em;
  margin: 10px 0 20px;
  color: #6a6a6a;
}
@media (min-width: 768px) and (max-width: 900px) {
  section.how-it-works h2 {
    font-size: 1.33333em;
    line-height: 1.16667em;
  }
}
@media (max-width: 767px) {
  section.how-it-works h2 {
    margin-top: 30px;
  }
}
section.how-it-works p {
  margin: 20px auto 0;
  max-width: 280px;
}
section.how-it-works .btn {
  width: auto;
  max-width: 300px;
  margin: 0 auto 50px;
}
section.how-it-works hr {
  height: 0;
  background: none;
  border: none;
  border-bottom: 1px dashed #d2d2d2;
}
@media (max-width: 767px) {
  section.how-it-works p {
    max-width: 300px;
    margin-left: auto;
    margin-right: auto;
  }
}
      CSS

      dnm_theme.update_column(:homepage_css, styles)
    end
  end

  def down
    remove_column :themes, :homepage_css
  end
end
