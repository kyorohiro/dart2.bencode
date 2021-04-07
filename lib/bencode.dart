import 'dart:typed_data' as data;
import 'dart:convert' as convert;

class Bencode {
  static final Bencoder _encoder = Bencoder();
  static final Bdecoder _decoder = Bdecoder();

  static data.Uint8List encode(Object obj) {
    return _encoder.enode(obj);
  }

  static Object decode(List<int> buffer) {
    return _decoder.decode(buffer);
  }

  static String toText(Object oo, String key, String def) {
    try {
      if (!(oo is Map)) {
        return def;
      }
      var p = oo as Map<String, dynamic>;
      if (!p.containsKey(key)) {
        return def;
      }
      if (!(p[key] is data.Uint8List)) {
        return def;
      }
      return convert.utf8.decode((p[key] as data.Uint8List).toList());
    } catch (e) {
      return def;
    }
  }

  static num toNum(Object oo, String key, num def) {
    try {
      if (!(oo is Map)) {
        return def;
      }
      Map p = oo as Map;
      if (!p.containsKey(key)) {
        return def;
      }
      if (!(p[key] is num)) {
        return def;
      }
      return p[key];
    } catch (e) {
      return def;
    }
  }

  static List toList(Object oo, String key) {
    try {
      if (!(oo is Map)) {
        return [];
      }
      Map p = oo as Map;
      if (!p.containsKey(key)) {
        return [];
      }
      if (!(p[key] is List)) {
        return [];
      }
      return p[key];
    } catch (e) {
      return [];
    }
  }

  static Map toMap(Object oo, String key) {
    try {
      if (!(oo is Map)) {
        return {};
      }
      Map p = oo as Map;
      if (!p.containsKey(key)) {
        return {};
      }
      if (!(p[key] is Map)) {
        return {};
      }
      return p[key];
    } catch (e) {
      return {};
    }
  }
}

class Bdecoder {
  BencodeParseError errorTmp = new BencodeParseError.empty();

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
    Map ret = new Map();
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
    var returnValue = 0;
    while (index < buffer.length && buffer[index] != 0x65) {
      if (!(0x30 <= buffer[index] && buffer[index] <= 0x39)) {
        throw errorTmp.update('bennumber', buffer, index);
      }
      returnValue = returnValue * 10 + (buffer[index++] - 0x30);
    }
    if (buffer[index++] != 0x65) {
      throw errorTmp.update('bennumber', buffer, index);
    }
    return returnValue;
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

class ByteBufferBuilder {
  int _length = 0;
  int get length => _length;
  final List<List<int>> _buffers = [];

  void clear() {
    _buffers.clear();
    _length = 0;
  }

  data.Uint8List toUint8List() {
    var ret = data.Uint8List(_length);
    var index = 0;
    for (var buffer in _buffers) {
      ret.setAll(index, buffer);
      index += buffer.length;
    }
    return ret;
  }

  void appendString(String v) {
    _buffers.add(convert.utf8.encode(v));
  }

  void addBytes(List<int> buffer, {int index: 0, int? length}) {
    _buffers.add(buffer.sublist(index, index + (length ?? buffer.length)));
  }
}

class Bencoder {
  ByteBufferBuilder builder = ByteBufferBuilder();

  data.Uint8List enode(Object obj) {
    builder.clear();
    encodeObject(obj);
    return builder.toUint8List();
  }

  void encodeString(String obj) {
    var buffer = convert.utf8.encode(obj);
    builder.appendString('' + buffer.length.toString() + ':' + obj);
  }

  void encodeUInt8List(data.Uint8List buffer) {
    builder.appendString('' + buffer.lengthInBytes.toString() + ':');
    builder.addBytes(buffer, index: 0, length: buffer.length);
  }

  void encodeNumber(num num) {
    builder.appendString('i' + num.toString() + 'e');
  }

  void encodeDictionary(Map obj) {
    var keys = obj.keys;
    builder.appendString('d');
    for (var key in keys) {
      encodeString(key);
      encodeObject(obj[key]);
      //   print('##-> ${key} : ${obj[key]}');//kiyo kiyo
    }
    builder.appendString('e');
  }

  void encodeList(List list) {
    builder.appendString('l');
    for (var i = 0; i < list.length; i++) {
      encodeObject(list[i]);
    }
    builder.appendString('e');
  }

  void encodeObject(Object? obj) {
    if (obj is num) {
      encodeNumber(obj);
    } else if (identical(obj, true)) {
      encodeString('true');
    } else if (identical(obj, false)) {
      encodeString('false');
    } else if (obj == null) {
      encodeString('null');
    } else if (obj is String) {
      encodeString(obj);
    } else if (obj is data.ByteBuffer) {
      encodeUInt8List(data.Uint8List.view(obj));
    } else if (obj is data.Uint8List) {
      encodeUInt8List(obj);
    } else if (obj is List) {
      encodeList(obj);
    } else if (obj is Map) {
      encodeDictionary(obj);
    }
  }
}

class BencodeParseError implements Exception {
  String log = '';

  BencodeParseError.empty() {}

  BencodeParseError(String s, data.Uint8List buffer, int index) {
    update(s, buffer, index);
  }

  BencodeParseError update(String s, List<int> buffer, int index) {
    log = s + '#' + buffer.toList().toString() + 'index=' + index.toString() + ':' + super.toString();
    return this;
  }

  String toString() {
    return log;
  }
}
