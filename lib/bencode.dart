import 'dart:typed_data' as data;
import 'dart:convert' as convert;
import 'package:info.kyorohiro.dart2.bencode/bytebufferbuilder.dart';
import 'package:info.kyorohiro.dart2.bencode/encoder.dart';
import 'package:info.kyorohiro.dart2.bencode/decoder.dart';

class Bencode {
  static final Bencoder _encoder = Bencoder(ByteBufferBuilderBasic());
  static final Bdecoder _decoder = Bdecoder();

  static data.Uint8List encode(dynamic obj) {
    return _encoder.enode(obj);
  }

  static dynamic decode(List<int> buffer) {
    return _decoder.decode(buffer);
  }

  static String toText(dynamic oo, String key, String def) {
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

  static num toNum(dynamic oo, String key, num def) {
    try {
      if (!(oo is Map)) {
        return def;
      }
      var p = oo as Map<String, dynamic>;
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

  static List<dynamic> toList(Object oo, String key) {
    try {
      if (!(oo is Map)) {
        return [];
      }
      var p = oo as Map<String, dynamic>;
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

  static Map<String, dynamic> toMap(dynamic oo, String key) {
    try {
      if (!(oo is Map)) {
        return {};
      }
      var p = oo as Map<String, dynamic>;
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
