function sendUpdateRequest(href, method) {
  $.ajax({
    url: href,
    method: method,
    dataType: 'script'
  });
}

function loadButtons(url, data, callback) {
  data = data || {};
  callback = callback || function(){};

  /* we use post for bulk show as we were hitting URL string limit with get requests */
  $.ajax({
    url: url,
    data: data,
    method: 'post',
    dataType: 'json'
  }).done(function(items){

    if (!items.wish_lists) {
      throw new Error('Invalid response from wish list buttons fetch');
    }

    items.wish_lists.forEach(callback);
  }).fail(function(){
    throw new Error('Unable to parse wish list buttons response');
  });
}

// There should be no jQuery dependency below this line,
// for ease of refactoring further down the line

function initializeFavoriteButtons(context){

  context = context || document;
  var els = context.querySelectorAll('.favorite-toggler [data-action-link]');

  if (els.length === 0){
    return;
  }

  var nonInitialized = Array.prototype.filter.call(els, function(el){
    return !el.getAttribute('data-favorite-toggler-initialized');
  });

  nonInitialized.forEach(function(el){
    el.setAttribute('data-favorite-toggler-initialized', true);
    el.addEventListener('click', function(e){
      e.preventDefault();
      e.stopPropagation();
      sendUpdateRequest(el.href, el.getAttribute('data-method'));
    });
  });
}

function load(context) {
  context = context || document;

  var elements = context.querySelectorAll('[data-add-favorite-button]');

  if (elements.length === 0) {
    return;
  }

  var url = elements[0].getAttribute('data-path-bulk');

  elements = Array.prototype.filter.call(elements, function(el){
    return !el.getAttribute('data-favorite-toggler-loaded');
  });

  var data = Array.prototype.map.call(elements, function(item){
    return {
      'object_id': item.getAttribute('data-object-id'),
      'wishlistable_type': item.getAttribute('data-wishlistable-type')
    };
  });

  loadButtons(url, { items: JSON.stringify(data) }, function(item){
    var el = document.getElementById('favorite-button-'+ item.wishlistable_type + '-' + item.id);
    el.setAttribute('data-favorite-toggler-loaded', true);

    el.innerHTML = item.content;
    var classes = el.getAttribute('data-link-to-classes');
    if (classes) {
      el.querySelector('a').className += ' ' + classes;
    }
    initializeFavoriteButtons(el);
  });
}


module.exports = load;
