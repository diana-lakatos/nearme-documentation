module.exports = class ActivityFeedController
  constructor: (@container) ->
    @currentUser = @container.data('current-user-id')
    @commentsSpamReports = @container.data('comments-spam-reports')
    @eventsSpamReports = @container.data('events-spam-reports')

    return unless @currentUser

    @initialize()
    @container.on 'next-page', =>
      @initialize()

  initialize: ->
    @showActionLinks()
    @showSpamReportLinks()

  showActionLinks: ->
    @container.find(".status-a[data-creator-id=#{@currentUser}], .comment-a[data-creator-id=#{@currentUser}], .comment-a[data-commentable-creator-id=#{@currentUser}]").addClass('is-current-user')

  showSpamReportLinks: ->
    for commentId in @commentsSpamReports
      @container.find(".comment-a[data-comment-id=#{commentId}] [data-cancel-report]").show()
      @container.find(".comment-a[data-comment-id=#{commentId}] [data-report-spam]").hide()

    for eventId in @eventsSpamReports
      @container.find(".status-a[data-activity-feed-event-id=#{eventId}] [data-cancel-report]").show()
      @container.find(".status-a[data-activity-feed-event-id=#{eventId}] [data-report-spam]").hide()



