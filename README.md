
bencode 


## LICENSE
Apache License


## Usage


```dart
import 'package:dart2.bencode/bencode.dart';
import 'package:dart2/dart2.dart';

{
  var out = Bencode.encode(1024);
  unit.expect('i1024e', convert.utf8.decode(out.toList()));
  num ret = Bencode.decode(out);
  unit.expect(1024, ret);
}

{
  var out = Bencode.encode('test');
  unit.expect('4:test', convert.utf8.decode(out.toList()));
  var text = Bencode.decode(out) as type.Uint8List;
  unit.expect('test', convert.utf8.decode(text.toList()));
}

{
  var l = [];
  l.add('test');
  l.add(1024);
  var out = Bencode.encode(l);
  unit.expect('l4:testi1024ee', convert.utf8.decode(out.toList()));

  List list = Bencode.decode(out);
  unit.expect('test', convert.utf8.decode(list[0].toList()));
  unit.expect(1024, list[1]);
}

{
  var m = <String, Object>{};
  m['test'] = 'test';
  m['value'] = 1024;
  var out = Bencode.encode(m);
  unit.expect('d4:test4:test5:valuei1024ee', convert.utf8.decode(out.toList()));

  Map me = Bencode.decode(out);
  unit.expect('test', convert.utf8.decode(me['test'].toList()));
  unit.expect(1024, me['value']);
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
