import 'dart:typed_data' as data;

class BencodeParseError implements Exception {
  String log = '';

  BencodeParseError.empty();

  BencodeParseError(String s, data.Uint8List buffer, int index) {
    update(s, buffer, index);
  }

  BencodeParseError update(String s, List<int> buffer, int index) {
    log = s + '#' + buffer.toList().toString() + 'index=' + index.toString() + ':' + super.toString();
    return this;
  }

  @override
  String toString() {
    return log;
  }
}
