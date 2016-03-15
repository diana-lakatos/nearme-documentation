module.exports = UtilUrl = {
  getParameterByName: (name)  ->
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
    regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
    results = regex.exec(location.search)
    if results == null
      ""
    else
      decodeURIComponent(results[1].replace(/\+/g, " "))

  assetUrl: (path) ->
    return  "#{window.NM_ASSET_HOST}/assets/#{path}"
}


