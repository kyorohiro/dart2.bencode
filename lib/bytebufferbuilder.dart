import 'dart:typed_data' show Uint8List;
import 'dart:convert' show utf8;

abstract class ByteBufferBuilder {
  int get length;
  void clear();
  Uint8List toUint8List();
  void appendString(String v);
  void addBytes(List<int> buffer, {int index: 0, int? length});
}

class ByteBufferBuilderBasic extends ByteBufferBuilder {
  int _length = 0;
  int get length => _length;
  final List<List<int>> _buffers = [];

  void clear() {
    _buffers.clear();
    _length = 0;
  }

  Uint8List toUint8List() {
    var ret = Uint8List(_length);
    var index = 0;
    for (var buffer in _buffers) {
      ret.setAll(index, buffer);
      index += buffer.length;
    }
    return ret;
  }

  void appendString(String v) {
    var _buffer = utf8.encode(v);
    _length += _buffer.length;
    _buffers.add(_buffer);
  }

  void addBytes(List<int> buffer, {int index: 0, int? length}) {
    var _buffer = buffer.sublist(index, index + (length ?? buffer.length));
    _length += _buffer.length;
    _buffers.add(_buffer);
  }
}
