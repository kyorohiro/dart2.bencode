library bencode.test;

import 'package:dart2.bencode/bencode.dart';
import 'package:test/test.dart' as unit;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;
import 'dart:math' as math;

void main() {
  unit.group('A group of tests', () {
    unit.test('bencode: string', () {
      var out = Bencode.encode('test');
      unit.expect('4:test', convert.utf8.decode(out.toList()));
      var text = Bencode.decode(out) as type.Uint8List;
      unit.expect('test', convert.utf8.decode(text.toList()));
    });

    unit.test('bencode: number', () {
      var out = Bencode.encode(1024);
      unit.expect('i1024e', convert.utf8.decode(out.toList()));
      num ret = Bencode.decode(out);
      unit.expect(1024, ret);
    });

//  {
//      type.Uint8List out = hetima.Bencode.encode(-10.24);
//      unit.expect('i-10.24e', convert.utf8.decode(out.toList()));
//      num ret = hetima.Bencode.decode(out);
//      unit.expect(-10.24, ret);
//  }

    unit.test('bencode: list', () {
      List l = [];
      l.add('test');
      l.add(1024);
      type.Uint8List out = Bencode.encode(l);
      unit.expect('l4:testi1024ee', convert.utf8.decode(out.toList()));

      List list = Bencode.decode(out);
      unit.expect('test', convert.utf8.decode(list[0].toList()));
      unit.expect(1024, list[1]);
    });

    unit.test('bencode: join', () {
      var pack = {};
      pack['action'] = 'join';
      pack['mode'] = 'broadcast';
      pack['id'] = Uuid.createUUID();
      var out = Bencode.encode(pack);

      unit.expect('d6:action4:join4:mode9:broadcast2:id36:' + pack['id'].toString() + 'e', convert.utf8.decode(out.toList()));
      Map m = Bencode.decode(out);
      unit.expect(pack['action'].toString(), convert.utf8.decode(m['action']).toString());
      unit.expect(pack['mode'].toString(), convert.utf8.decode(m['mode']).toString());
      unit.expect(pack['id'].toString(), convert.utf8.decode(m['id']).toString());
    });

    unit.test('bencode: dictionary', () {
      var m = <String, Object>{};
      m['test'] = 'test';
      m['value'] = 1024;
      var out = Bencode.encode(m);
      unit.expect('d4:test4:test5:valuei1024ee', convert.utf8.decode(out.toList()));

      Map me = Bencode.decode(out);
      unit.expect('test', convert.utf8.decode(me['test'].toList()));
      unit.expect(1024, me['value']);
    });
  });
}

class Uuid {
  static final math.Random _random = math.Random();

  static String createUUID() {
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
  }

  static String s4() {
    return (_random.nextInt(0xFFFF) + 0x10000).toRadixString(16).substring(0, 4);
  }
}
