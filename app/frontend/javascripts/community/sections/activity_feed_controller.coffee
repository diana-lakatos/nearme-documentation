module.exports = class ActivityFeedController
  constructor: (@container) ->
    @currentUser = @container.data('current-user-id')
    @commentsSpamReports = @container.data('comments-spam-reports')
    @eventsSpamReports = @container.data('events-spam-reports')
    @initialize()
    @container.on 'next-page', =>
      @initialize()

  initialize: ->
    @showDeleteCommentLinks()
    @showSpamReportLinks()

  showDeleteCommentLinks: ->
    @container.find(".comment-a[data-creator-id=#{@currentUser}] [data-remove-comment]").show()
    @container.find(".comment-a[data-commentable-creator-id=#{@currentUser}] [data-remove-comment]").show()

  showSpamReportLinks: ->
    for commentId in @commentsSpamReports
      @container.find(".comment-a[data-comment-id=#{commentId}] [data-cancel-report]").show()
      @container.find(".comment-a[data-comment-id=#{commentId}] [data-report-spam]").hide()

    for eventId in @eventsSpamReports
      @container.find(".status-a[data-activity-feed-event-id=#{eventId}] [data-cancel-report]").show()
      @container.find(".status-a[data-activity-feed-event-id=#{eventId}] [data-report-spam]").hide()



