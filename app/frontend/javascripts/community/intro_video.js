/* global YT */
var IntroVideo,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('jquery.cookie/jquery.cookie');

IntroVideo = function() {
  function IntroVideo(container) {
    this.onPlayerReady = bind(this.onPlayerReady, this);
    this.onPlayerStateChange = bind(this.onPlayerStateChange, this);
    this.loadApi();
    this.container = $(container);
    this.videoWrap = this.container.find('.intro-video-wrapper');
    this.iframe = this.videoWrap.find('iframe');
    this.overlay = this.container.find('.intro-video-overlay');
    this.closeButton = this.container.find('.intro-video-close');
    this.cookieName = 'hide_intro_video';
    this.videoAspectRatio = 1280 / 720;
    this.initStructure();
    this.bindEvents();
  }

  IntroVideo.prototype.loadApi = function() {
    var firstScriptTag, tag;
    tag = document.createElement('script');
    tag.src = 'https://www.youtube.com/iframe_api';
    firstScriptTag = document.getElementsByTagName('script')[0];
    return firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  };

  IntroVideo.prototype.initStructure = function() {
    this.trigger = $(
      '<button type="button" id="intro-video-toggler">Play Video <span>Again</span></button>'
    );
    return this.trigger.appendTo('body');
  };

  IntroVideo.prototype.bindEvents = function() {
    this.trigger.on(
      'click',
      function(_this) {
        return function(e) {
          e.preventDefault();
          e.stopPropagation();
          return _this.showVideo();
        };
      }(this)
    );
    this.overlay.add(this.closeButton).add(this.videoWrap).on(
      'click.introvideo',
      function(_this) {
        return function() {
          return _this.hideVideo();
        };
      }(this)
    );
    $(window).on(
      'resize',
      function(_this) {
        return function() {
          return _this.resizePlayer();
        };
      }(this)
    );
    return window.onYouTubeIframeAPIReady = function(_this) {
      return function() {
        return _this.player = new YT.Player('intro-player', {
          height: 1280,
          width: 720,
          videoId: 'cBamideLh3g',
          events: { onReady: _this.onPlayerReady, onStateChange: _this.onPlayerStateChange },
          playerVars: { rel: 0, fs: 0 }
        });
      };
    }(this);
  };

  IntroVideo.prototype.bindOnShow = function() {
    return $('body').on(
      'keydown.introvideo',
      function(_this) {
        return function(e) {
          if (e.which === 27) {
            return _this.hideVideo();
          }
        };
      }(this)
    );
  };

  IntroVideo.prototype.onPlayerStateChange = function(event) {
    if (event.data === YT.PlayerState.ENDED) {
      return this.hideVideo();
    }
  };

  IntroVideo.prototype.onPlayerReady = function(event) {
    if (this.container.hasClass('inactive')) {
      return;
    }
    if (!Modernizr.touchevents) {
      event.target.mute();
      event.target.playVideo();
    }
    this.bindOnShow();
    return this.resizePlayer();
  };

  IntroVideo.prototype.hideVideo = function() {
    this.container.addClass('inactive');
    $.cookie(this.cookieName, 1, { expires: 28, path: '/' });
    if (this.player.stopVideo) {
      this.player.stopVideo();
    }
    return $('body').off('*.introvideo');
  };

  IntroVideo.prototype.resizePlayer = function() {
    var wrapperAspectRatio, x, y;
    x = this.videoWrap.width() - 40;
    y = this.videoWrap.height() - 40;
    wrapperAspectRatio = x / y;
    if (!(this.iframe.length > 0)) {
      this.iframe = this.videoWrap.find('iframe');
    }
    if (this.iframe.length === 0) {
      return;
    }
    if (wrapperAspectRatio > this.videoAspectRatio) {
      x = y * this.videoAspectRatio;
    } else if (wrapperAspectRatio < this.videoAspectRatio) {
      y = x / this.videoAspectRatio;
    }
    x = Math.round(x);
    y = Math.round(y);
    return this.iframe.css({ width: x, height: y });
  };

  IntroVideo.prototype.showVideo = function() {
    this.container.removeClass('inactive');
    this.resizePlayer();
    if (!Modernizr.touchevents) {
      if (this.player.playVideo) {
        this.player.playVideo();
      }
    }
    return this.bindOnShow();
  };

  return IntroVideo;
}();

module.exports = IntroVideo;
