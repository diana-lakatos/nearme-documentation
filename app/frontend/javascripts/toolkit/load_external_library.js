//@flow

let libs: Map<string, Promise<mixed>> = new Map();

function loadExternalLibrary({ name, url }: { name?: string, url: string } = {}): Promise<mixed> {
  if (name && window[name]) {
    return Promise.resolve(window[name]);
  }

  let existing = libs.get(url);
  if (existing) {
    return existing;
  }

  let p = new Promise((resolve, reject) => {
    let s = document.createElement('script');
    s.src = url;
    s.addEventListener('load', function() {
      if (name && window[name]) {
        resolve(window[name]);
        return;
      } else if (name && !window[name]) {
        reject(`Unable to load ${name} library from ${url}`);
        return;
      }

      resolve();
    });

    if (document.head instanceof HTMLElement) {
      document.head.appendChild(s);
    }
  });

  libs.set(url, p);
  return p;
}

module.exports = loadExternalLibrary;
