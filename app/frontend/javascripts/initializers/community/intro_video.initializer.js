var el = $('#intro-video');
if (el.length > 0) {
  require.ensure('../../community/intro_video', (require)=>{
    var IntroVideo = require('../../community/intro_video');
    return new IntroVideo(el);
  });
}
