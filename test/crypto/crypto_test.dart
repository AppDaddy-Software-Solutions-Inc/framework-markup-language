import 'package:flutter_test/flutter_test.dart';
import 'package:fml/crypto/crypto.dart';

void main() {
  group('Cryptography', () {

    test("Encrypt 'Hello'", () {
      expect(Cryptography.encrypt(text: 'Hello'), 'UZu6uy8IA3qWHgIvCn04tQ==');
    });

    test("Decrypt 'UZu6uy8IA3qWHgIvCn04tQ==' ('Hello')", () {
      expect(Cryptography.decrypt(text: 'UZu6uy8IA3qWHgIvCn04tQ=='), 'Hello');
    });

  });
}