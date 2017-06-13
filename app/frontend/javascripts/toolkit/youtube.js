// @flow
// global YT

let ytiapi;

module.exports.getYouTubeIframeApi = function(): Promise<any> {
  if (ytiapi) {
    return ytiapi;
  }

  ytiapi = new Promise((resolve, reject) => {
    window.onYouTubeIframeAPIReady = function() {
      if (window.YT) {
        resolve(window.YT);
        return;
      }

      reject('Unable to load YT api');
    };

    let tag = document.createElement('script');

    tag.setAttribute('src', 'https://www.youtube.com/iframe_api');
    let head = document.querySelector('head');
    if (!head) {
      throw new Error('Invalid context, must be called in a browser');
    }
    head.insertAdjacentElement('afterbegin', tag);
  });

  return ytiapi;
};
