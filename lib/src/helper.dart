import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Converts base 10 int into String representation of base 16 int and takes the last two digets.
String dec2hex(int dec) {
  final radixString = '0${dec.toRadixString(16)}';
  return radixString.substring(radixString.length - 2);
}

/// Generates a random code verifier
String generatePKCEVerifier() {
  const verifierLength = 56;
  final array = Uint32List(verifierLength);
  final random = Random();
  for (var i = 0; i < verifierLength; i++) {
    array[i] = random.nextInt(255);
  }
  return array.map(dec2hex).join('');
}

String generatePKCEChallenge(String verifier) {
  final hash = sha256.convert(verifier.codeUnits);
  return base64Encode(hash.bytes);
}
