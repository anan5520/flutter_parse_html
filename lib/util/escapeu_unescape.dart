

class EscapeUnescape{

   static String unescape(String src) {
    StringBuffer tmp = new StringBuffer();
    int lastPos = 0, pos = 0;
    String ch;
    while (lastPos < src.length) {
      pos = src.indexOf("%", lastPos);
      if (pos == lastPos) {
        int code = hexToInt(src
            .substring(pos + 1, pos + 3));
        ch = String.fromCharCode(code) ;
        tmp.write(ch);
        lastPos = pos + 3;
      } else {
        if (pos == -1) {
          tmp.write(src.substring(lastPos));
          lastPos = src.length;
        } else {
          tmp.write(src.substring(lastPos, pos));
          lastPos = pos;
        }
      }
    }
    return tmp.toString();
  }

  static int  hexToInt(String hex) {
     int val = 0;
     int len = hex.length;
     for (int i = 0; i < len; i++) {
       int hexDigit = hex.codeUnitAt(i);
       if (hexDigit >= 48 && hexDigit <= 57) {
         val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
       } else if (hexDigit >= 65 && hexDigit <= 70) {
         // A..F
         val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
       } else if (hexDigit >= 97 && hexDigit <= 102) {
         // a..f
         val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
       } else {
         throw new FormatException("Invalid hexadecimal value");
       }
     }
     return val;
   }
}
