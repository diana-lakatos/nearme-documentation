Deface::Override.new(virtual_path: "spree/admin/shared/_header",
                     replace: '#header',
                     partial: 'layouts/navbar',
                     name: "admin_header")
