import 'dart:typed_data' as data;
import 'dart:convert' as convert;
import './bytebufferbuilder.dart';
import './exception.dart';

class Bdecoder {
  var errorTmp = BencodeParseError.empty();

  int index = 0;
  Object decode(List<int> buffer) {
    index = 0;
    return decodeBenObject(buffer);
  }

  Object decodeBenObject(List<int> buffer) {
    if (0x30 <= buffer[index] && buffer[index] <= 0x39) {
      //0-9
      return decodeBytes(buffer);
    } else if (0x69 == buffer[index]) {
      // i
      return decodeNumber(buffer);
    } else if (0x6c == buffer[index]) {
      // l
      return decodeList(buffer);
    } else if (0x64 == buffer[index]) {
      // d
      return decodeDiction(buffer);
    }
    throw errorTmp.update('benobject', buffer, index);
  }

  Map decodeDiction(List<int> buffer) {
    var ret = {};
    if (buffer[index++] != 0x64) {
      throw errorTmp.update('bendiction', buffer, index);
    }

    ret = decodeDictionElements(buffer);

    if (buffer[index++] != 0x65) {
      throw errorTmp.update('bendiction', buffer, index);
    }
    return ret;
  }

  Map decodeDictionElements(List<int> buffer) {
    var ret = {};
    while (index < buffer.length && buffer[index] != 0x65) {
      var keyAsList = decodeBenObject(buffer) as data.Uint8List;
      var key = convert.utf8.decode(keyAsList.toList());
      ret[key] = decodeBenObject(buffer);
    }
    return ret;
  }

  List decodeList(List<int> buffer) {
    if (buffer[index++] != 0x6c) {
      throw errorTmp.update('benlist', buffer, index);
    }
    var ret = decodeListElemets(buffer);
    if (buffer[index++] != 0x65) {
      throw errorTmp.update('benlist', buffer, index);
    }
    return ret;
  }

  List decodeListElemets(List<int> buffer) {
    var ret = [];
    while (index < buffer.length && buffer[index] != 0x65) {
      ret.add(decodeBenObject(buffer));
    }
    return ret;
  }

  num decodeNumber(List<int> buffer) {
    if (buffer[index++] != 0x69) {
      throw errorTmp.update('bennumber', buffer, index);
    }
    num returnValue = 0;
    var plusMinus = 1;
    var dot = 0;
    while (index < buffer.length && buffer[index] != 0x65) {
      if (dot != 0) {
        dot *= 10;
      }
      if (index == 1 && buffer[index] == 0x2d) {
        plusMinus = -1;
      } else if (dot == 0 && buffer[index] == 0x2e) {
        dot = 1;
      } else if (0x30 <= buffer[index] && buffer[index] <= 0x39) {
        returnValue = returnValue * 10 + (buffer[index] - 0x30);
      } else {
        throw errorTmp.update('bennumber', buffer, index);
      }

      index++;
    }

    if (buffer[index++] != 0x65) {
      throw errorTmp.update('bennumber', buffer, index);
    }
    if (dot != 0) {
      return plusMinus * returnValue / dot;
    } else {
      return (plusMinus * returnValue).toInt();
    }
  }

  data.Uint8List decodeBytes(List<int> buffer) {
    var length = 0;
    while (index < buffer.length && buffer[index] != 0x3a) {
      if (!(0x30 <= buffer[index] && buffer[index] <= 0x39)) {
        throw errorTmp.update('benstring', buffer, index);
      }
      length = length * 10 + (buffer[index++] - 0x30);
    }
    if (buffer[index++] != 0x3a) {
      throw errorTmp.update('benstring', buffer, index);
    }
    var ret = data.Uint8List.fromList(buffer.sublist(index, index + length));
    index += length;
    return ret;
  }
}
