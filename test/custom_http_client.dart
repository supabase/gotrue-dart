import 'dart:convert';

import 'package:http/http.dart';

class CustomHttpClient extends BaseClient {
  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    //Return custom status code to check for usage of this client.
    return StreamedResponse(
      request.finalize(),
      420,
      request: request,
    );
  }
}

class NoEmailConfirmationHttpClient extends BaseClient {
  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final now = DateTime.now().toIso8601String();
    return StreamedResponse(
      Stream.value(
        utf8.encode(
          jsonEncode(
            {
              'id': 'ef507d02-ce6a-4b3a-a8a6-6f0e14740136',
              'aud': 'authenticated',
              'role': 'authenticated',
              'email': 'fake1@email.com',
              'phone': '',
              'confirmation_sent_at': now,
              'app_metadata': {
                'provider': 'email',
                'providers': ['email']
              },
              'user_metadata': {},
              'identities': [
                {
                  'id': 'ef507d02-ce6a-4b3a-a8a6-6f0e14740136',
                  'user_id': 'ef507d02-ce6a-4b3a-a8a6-6f0e14740136',
                  'identity_data': {
                    'email': 'fake1@email.com',
                    'sub': 'ef507d02-ce6a-4b3a-a8a6-6f0e14740136'
                  },
                  'provider': 'email',
                  'last_sign_in_at': now,
                  'created_at': now,
                  'updated_at': now
                }
              ],
              'created_at': now,
              'updated_at': now,
            },
          ),
        ),
      ),
      201,
      request: request,
    );
  }
}
