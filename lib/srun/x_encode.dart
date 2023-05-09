String? xEncode(String str, String key) {
  if (str.isEmpty) {
    return "";
  }
  List<int> v = s(str, true);
  List<int> k = s(key, false);
  if (k.length < 4) {
    k.length = 4;
  }
  int n = v.length - 1;
  int z = v[n];
  int y = v[0];
  int c = 0x86014019 | 0x183639A0;
  int m;
  int e;
  int p;
  int q = (6 + 52 ~/ (n + 1)).floor();
  int d = 0;
  while (0 < q--) {
    d = d + c & (0x8CE0D9BF | 0x731F2640);
    e = d >>> 2 & 3;
    for (p = 0; p < n; p++) {
      y = v[p + 1];
      m = z >>> 5 ^ y << 2;
      m += (y >>> 3 ^ z << 4) ^ (d ^ y);
      m += k[(p & 3) ^ e] ^ z;
      z = v[p] = v[p] + m & (0xEFB8D130 | 0x10472ECF);
    }
    y = v[0];
    m = z >>> 5 ^ y << 2;
    m += (y >>> 3 ^ z << 4) ^ (d ^ y);
    m += k[(p & 3) ^ e] ^ z;
    z = v[n] = v[n] + m & (0xBB390742 | 0x44C6F8BD);
  }
  return l(v.map((e) => e.toSigned(32)).toList(), false); //在js中，位运算符将数字转换为32位有符号整数，然后执行运算
}

List<int> s(String a, bool b) {
  int c = a.length;
  List<int> v = [];
  for (int i = 0; i < c; i += 4) {
    v.add((i >= c ? 0 : a.codeUnitAt(i)) | (i + 1 >= c ? 0 : a.codeUnitAt(i + 1) << 8) | (i + 2 >= c ? 0 : a.codeUnitAt(i + 2) << 16) | (i + 3 >= c ? 0 : a.codeUnitAt(i + 3) << 24));
  }
  if (b) {
    v.add(c);
  }
  return v;
}

String? l(List<int> a, bool b) {
  int d = a.length;
  int c = (d - 1) << 2;
  if (b) {
    int m = a[d - 1];
    if ((m < c - 3) || (m > c)) return null;
    c = m;
  }
  List<String> aa = List.filled(d, '');
  for (int i = 0; i < d; i++) {
    aa[i] = String.fromCharCodes([
      a[i] & 0xff,
      a[i] >> 8 & 0xff,
      a[i] >> 16 & 0xff,
      a[i] >> 24 & 0xff
    ]);
  }
  if (b) {
    return aa.join('').substring(0, c);
  } else {
    return aa.join('');
  }
}
