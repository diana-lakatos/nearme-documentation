function getImageTypeFromArrayBuffer(buffer) {
  var arr = (new Uint8Array(buffer)).subarray(0, 4);
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
}

module.exports = getImageTypeFromArrayBuffer;
