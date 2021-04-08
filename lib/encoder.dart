import 'dart:typed_data' as data;
import 'dart:convert' as convert;
import './bytebufferbuilder.dart';

class Bencoder {
  final ByteBufferBuilder builder;
  Bencoder(this.builder);
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
