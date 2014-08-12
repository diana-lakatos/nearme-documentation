Deface::Override.new(virtual_path: "spree/admin/shared/_configuration_menu",
                     replace_contents: 'nav.menu ul.sidebar',
                     partial: 'shared/spree_admin_configuration_menu',
                     name: "admin_configuration_menu")
