import 'package:gotrue/gotrue.dart';

class OpenIDConnectCredentials {
  final String idToken;
  final String nonce;
  final Provider? provider;
  final String? clientId;
  final String? issuer;

  OpenIDConnectCredentials({
    required this.idToken,
    required this.nonce,
    this.provider,
    this.clientId,
    this.issuer,
  });
}
