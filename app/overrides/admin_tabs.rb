Deface::Override.new(virtual_path: "spree/admin/shared/_menu",
                     replace_contents: 'ul[data-hook="admin_tabs"]',
                     partial: 'shared/spree_admin_tabs',
                     name: "admin_tabs")
