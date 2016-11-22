var el = $('.content-container[data-activity-feed]');
if (el.length > 0) {
  require.ensure('../../community/sections/activity_feed_controller',(require)=>{
    var ActivityFeedController = require('../../community/sections/activity_feed_controller');
    return new ActivityFeedController(el);
  });
}

