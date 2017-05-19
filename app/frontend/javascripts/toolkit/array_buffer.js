// Converts an ArrayBuffer directly to base64, without any intermediate 'convert to string then
// use window.btoa' step. According to my tests, this appears to be a faster approach:
// http://jsperf.com/encoding-xhr-image-data/5

module.exports.base64ArrayBuffer = function(arrayBuffer) {
  var base64 = '';
  var encodings = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

  var bytes = new Uint8Array(arrayBuffer);
  var byteLength = bytes.byteLength;
  var byteRemainder = byteLength % 3;
  var mainLength = byteLength - byteRemainder;

  var a, b, c, d;
  var chunk;

  // Main loop deals with bytes in chunks of 3
  for (var i = 0; i < mainLength; i = i + 3) {
    // Combine the three bytes into a single integer
    chunk = bytes[i] << 16 | bytes[i + 1] << 8 | bytes[i + 2];

    // Use bitmasks to extract 6-bit segments from the triplet
    a = (chunk & 16515072) >> 18;
    // 16515072 = (2^6 - 1) << 18
    b = (chunk & 258048) >> 12;
    // 258048   = (2^6 - 1) << 12
    c = (chunk & 4032) >> 6;
    // 4032     = (2^6 - 1) << 6
    d = chunk & 63;
    // 63       = 2^6 - 1
    // Convert the raw binary segments to the appropriate ASCII encoding
    base64 += encodings[a] + encodings[b] + encodings[c] + encodings[d];
  }

  // Deal with the remaining bytes and padding
  if (byteRemainder == 1) {
    chunk = bytes[mainLength];

    a = (chunk & 252) >> 2;
    // 252 = (2^6 - 1) << 2
    // Set the 4 least significant bits to zero
    b = (chunk & 3) << 4;
    // 3   = 2^2 - 1
    base64 += encodings[a] + encodings[b] + '==';
  } else if (byteRemainder == 2) {
    chunk = bytes[mainLength] << 8 | bytes[mainLength + 1];

    a = (chunk & 64512) >> 10;
    // 64512 = (2^6 - 1) << 10
    b = (chunk & 1008) >> 4;
    // 1008  = (2^6 - 1) << 4
    // Set the 2 least significant bits to zero
    c = (chunk & 15) << 2;
    // 15    = 2^4 - 1
    base64 += encodings[a] + encodings[b] + encodings[c] + '=';
  }

  return base64;
};

// http://stackoverflow.com/questions/7584794/accessing-jpeg-exif-rotation-data-in-javascript-on-the-client-side
// returns
// -2: not jpeg
// -1: not defined
// 1: normal
// 2: flipped
// 3: 180deg normal
// 4: 180deg flipped
// 5: 90deg counterclockwise flipped
// 6: 90deg counterclockwise normal
// 7: 90deg clockwise flipped
// 8: 90deg clockwise normal
module.exports.getImageOrientationFromArrayBuffer = function(buffer) {
  var view, length, offset = 2, check, marker, little, tags;

  view = new DataView(buffer);
  /* not a JPEG */
  if (view.getUint16(0, false) != 65496) {
    return -2;
  }

  length = view.byteLength;

  while (offset < length) {
    marker = view.getUint16(offset, false);
    offset += 2;
    if (marker == 65505) {
      check = view.getUint32(offset += 2, false) == 1165519206;
      if (!check) {
        return -1;
      }
      little = view.getUint16(offset += 6, false) == 18761;
      offset += view.getUint32(offset + 4, little);
      tags = view.getUint16(offset, little);
      offset += 2;
      for (var i = 0; i < tags; i++) {
        if (view.getUint16(offset + i * 12, little) == 274) {
          return view.getUint16(offset + i * 12 + 8, little);
        }
      }
    } else if ((marker & 65280) != 65280) {
      break;
    } else {
      offset += view.getUint16(offset, false);
    }
  }

  return -1;
};

module.exports.getImageTypeFromArrayBuffer = function(buffer) {
  var arr = new Uint8Array(buffer).subarray(0, 4);
  var header = '';
  for (var i = 0; i < arr.length; i++) {
    header += arr[i].toString(16);
  }

  switch (header) {
    case '89504e47':
      return 'image/png';

    case '47494638':
      return 'image/gif';

    case 'ffd8ffe0':
    case 'ffd8ffe1':
    case 'ffd8ffe2':
      return 'image/jpeg';
  }
};
