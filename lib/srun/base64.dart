String _PADCHAR = "=";
String _ALPHA = "LVoJPiCN2R8G90yg+hmFHuacZ1OWMnrsSTXkYpUq/3dlbfKwv6xztjI7DeBE45QA";
String _VERSION = "1.0";

int _getbyte64(String s, int i) {
  final idx = _ALPHA.indexOf(s[i]);
  if (idx == -1) {
    throw FormatException('Cannot decode base64');
  }
  return idx;
}

void _setAlpha(String s) {
  _ALPHA = s;
}

int _getbyte(String s, int i) {
  final x = s.codeUnitAt(i);
  if (x > 255) {
    throw Exception('INVALID_CHARACTER_ERR: DOM Exception 5');
  }
  return x;
}

String encode(String? s) {
  if (s == null || s.isEmpty) {
    return '';
  }
  final x = <String>[];
  final imax = s.length - s.length % 3;
  var i = 0;
  for (; i < imax; i += 3) {
    final b10 = (_getbyte(s, i) << 16) | (_getbyte(s, i + 1) << 8) | _getbyte(s, i + 2);
    x.add(_ALPHA[b10 >> 18]);
    x.add(_ALPHA[(b10 >> 12) & 63]);
    x.add(_ALPHA[(b10 >> 6) & 63]);
    x.add(_ALPHA[b10 & 63]);
  }
  switch (s.length - imax) {
    case 1:
      final b10 = _getbyte(s, i) << 16;
      x.add(_ALPHA[b10 >> 18] + _ALPHA[(b10 >> 12) & 63] + _PADCHAR + _PADCHAR);
      break;
    case 2:
      final b10 = (_getbyte(s, i) << 16) | (_getbyte(s, i + 1) << 8);
      x.add(_ALPHA[b10 >> 18] + _ALPHA[(b10 >> 12) & 63] + _ALPHA[(b10 >> 6) & 63] + _PADCHAR);
      break;
  }
  return x.join('');
}
