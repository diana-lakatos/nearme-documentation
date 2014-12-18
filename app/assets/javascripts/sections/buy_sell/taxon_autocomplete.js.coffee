class @TaxonAutocomplete
  constructor: (@form, token) ->
    if $("#boarding_form_category").length > 0
      $("#boarding_form_category").select2
        placeholder: "Enter a category"
        multiple: true
        initSelection: (element, callback) ->
          url = '/instance_buy_sell/api/taxons?ids=' + element.val()

          $.getJSON url, null, (data) ->
            callback data["taxons"]

        ajax:
          url: '/instance_buy_sell/api/taxons'
          datatype: "json"
          data: (term, page) ->
            per_page: 50
            page: page
            q:
              name_cont: term
            token: token;

          results: (data, page) ->
            more = page < data.pages
            results: data["taxons"]
            more: more

        formatResult: (taxon) ->
          taxon.pretty_name

        formatSelection: (taxon) ->
          taxon.pretty_name