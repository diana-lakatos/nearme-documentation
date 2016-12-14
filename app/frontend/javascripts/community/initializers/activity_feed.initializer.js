var el = $('.content-container[data-activity-feed]');
if (el.length > 0) {
  require.ensure('../sections/activity_feed_controller',(require)=>{
    var ActivityFeedController = require('../sections/activity_feed_controller');
    return new ActivityFeedController(el);
  });
}

