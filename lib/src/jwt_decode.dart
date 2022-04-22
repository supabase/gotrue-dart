import 'dart:convert';

Map<String, dynamic> jwtDecode(String token) {
  final parts = token.split('.');
  // Check if the JWT consists header, payload, and signature
  if (parts.length != 3) {
    throw Exception('invalid token');
  }

  String str = parts[1].replaceAll('-', '+').replaceAll('_', '/');

  switch (str.length % 4) {
    case 0:
      break;
    case 2:
      str += '==';
      break;
    case 3:
      str += '=';
      break;
    default:
      throw Exception('Illegal base64url string!');
  }

  // Returning the payload as a map
  final payload = utf8.decode(base64Url.decode(str));
  final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
  return payloadMap;
}
