class @TaxonAutocomplete
  constructor: (@form) ->
    if $("#boarding_form_product_form_taxon_ids, #product_form_taxon_ids").length > 0
      $("#boarding_form_product_form_taxon_ids, #product_form_taxon_ids").select2
        placeholder: "Enter a category"
        multiple: true
        initSelection: (element, callback) ->
          url = '/dashboard/api/taxons?ids=' + element.val()

          $.getJSON url, null, (data) ->
            callback data

        ajax:
          url: '/dashboard/api/taxons'
          datatype: "json"
          data: (term, page) ->
            per_page: 50
            page: page
            q:
              name_cont: term

          results: (data, page) ->
            more = page < data.pages
            results: data
            more: more

        formatResult: (taxon) ->
          taxon.pretty_name

        formatSelection: (taxon) ->
          taxon.pretty_name