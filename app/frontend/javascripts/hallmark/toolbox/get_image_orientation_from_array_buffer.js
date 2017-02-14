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

function getImageOrientationFromArrayBuffer(buffer) {
  var
    view,
    length,
    offset = 2,
    check,
    marker,
    little,
    tags;

  view = new DataView(buffer);
  /* not a JPEG */
  if (view.getUint16(0, false) != 0xFFD8) {
    return -2;
  }

  length = view.byteLength;

  while (offset < length) {
    marker = view.getUint16(offset, false);
    offset += 2;
    if (marker == 0xFFE1) {
      check = view.getUint32(offset += 2, false) == 0x45786966;
      if (!check) {
        return -1;
      }
      little = view.getUint16(offset += 6, false) == 0x4949;
      offset += view.getUint32(offset + 4, little);
      tags = view.getUint16(offset, little);
      offset += 2;
      for (var i = 0; i < tags; i++) {
        if (view.getUint16(offset + (i * 12), little) == 0x0112) {
          return view.getUint16(offset + (i * 12) + 8, little);
        }
      }
    } else if ((marker & 0xFF00) != 0xFF00) {
      break;
    } else {
      offset += view.getUint16(offset, false);
    }
  }

  return -1;
}

module.exports = getImageOrientationFromArrayBuffer;
