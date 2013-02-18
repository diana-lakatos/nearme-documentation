window.analytics = {
  track: function() {
    mixpanel.track(arguments);
  },
  trackLink: function() {
    mixpanel.track_links(arguments);
  },
  trackForm: function() {
    mixpanel.track_forms(arguments);
  },
  trackPageView: function() {
    mixpanel.track_pageview(arguments);
  },
  identify: function() {
    mixpanel.identify(arguments);
  },
  alias: function() {
    mixpanel.alias(arguments);
  },
  set: function() {
    mixpanel.people.set(arguments);
  },
  increment: function() {
    mixpanel.people.increment(arguments);
  },
  trackCharge: function() {
    mixpanel.people.track_charge(arguments);
  }
}
