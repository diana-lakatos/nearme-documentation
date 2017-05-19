var ActivityFeedController;

ActivityFeedController = function() {
  function ActivityFeedController(container) {
    this.container = container;
    this.currentUser = this.container.data('current-user-id');
    this.commentsSpamReports = this.container.data('comments-spam-reports');
    this.eventsSpamReports = this.container.data('events-spam-reports');
    if (!this.currentUser) {
      return;
    }
    this.initialize();
    this.container.on(
      'next-page',
      function(_this) {
        return function() {
          return _this.initialize();
        };
      }(this)
    );
  }

  ActivityFeedController.prototype.initialize = function() {
    this.showDeleteCommentLinks();
    return this.showSpamReportLinks();
  };

  ActivityFeedController.prototype.showDeleteCommentLinks = function() {
    this.container
      .find('.comment-a[data-creator-id=' + this.currentUser + '] [data-remove-comment]')
      .show();
    return this.container
      .find(
        '.comment-a[data-commentable-creator-id=' + this.currentUser + '] [data-remove-comment]'
      )
      .show();
  };

  ActivityFeedController.prototype.showSpamReportLinks = function() {
    var commentId, eventId, i, j, len, len1, ref, ref1, results;
    ref = this.commentsSpamReports;
    for (i = 0, len = ref.length; i < len; i++) {
      commentId = ref[i];
      this.container
        .find('.comment-a[data-comment-id=' + commentId + '] [data-cancel-report]')
        .show();
      this.container
        .find('.comment-a[data-comment-id=' + commentId + '] [data-report-spam]')
        .hide();
    }
    ref1 = this.eventsSpamReports;
    results = [];
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      eventId = ref1[j];
      this.container
        .find('.status-a[data-activity-feed-event-id=' + eventId + '] [data-cancel-report]')
        .show();
      results.push(
        this.container
          .find('.status-a[data-activity-feed-event-id=' + eventId + '] [data-report-spam]')
          .hide()
      );
    }
    return results;
  };

  return ActivityFeedController;
}();

module.exports = ActivityFeedController;
