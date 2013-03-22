(function() {
  function  callMixpanel(function_name, args) {
    mixpanel[function_name].apply(mixpanel, args);
  }

  function callMixpanelPeople(function_name, args) {
    mixpanel.people[function_name].apply(mixpanel.people, args);
  }

  window.analytics = {
    init: function() {
      callMixpanel('init', arguments);
    },
    track: function() {
      callMixpanel('track', arguments);
    },
    trackLink: function() {
      callMixpanel('track_links', arguments);
    },
    trackForm: function() {
      callMixpanel('track_forms', arguments);
    },
    trackPageView: function() {
      callMixpanel('track_pageview', arguments);
    },
    identify: function() {
      callMixpanel('identify', arguments);
    },
    alias: function() {
      callMixpanel('alias', arguments);
    },
    set: function() {
      callMixpanelPeople('set', arguments);
    },
    increment: function() {
      callMixpanelPeople('increment', arguments);
    },
    trackCharge: function() {
      callMixpanelPeople('track_charge', arguments);
    }
  }
})();
