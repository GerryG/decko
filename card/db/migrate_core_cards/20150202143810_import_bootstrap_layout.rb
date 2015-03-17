# -*- encoding : utf-8 -*-

class ImportBootstrapLayout < Card::CoreMigration
  def up
    layout = Card.fetch "Default Layout"
    if layout
      layout.name = "Classic Layout"
      layout.update_referencers = true
      layout.save!
    end
    
    import_json "bootstrap_layout.json"
    Card.create! :name=>'style: bootstrap theme', :type_code=>:css, :codename=>'bootstrap_theme_css'
    Card.create! :name=>'style: bootstrap', :type_code=>:css, :codename=>'bootstrap_css'
    Card.create! :name=>'script: bootstrap', :type_code=>:js, :codename=>'bootstrap_js'
  end
end
