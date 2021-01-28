# `gotrue-dart`

Dart client for the [GoTrue](https://github.com/netlify/gotrue) API.

## Using

The usage should be the same as gotrue-js except:

Oauth2:

- `signIn` with oauth2 provider only return provider url. Users have to launch that url to continue the auth flow. I recommend to use [url_launcher](https://pub.dev/packages/url_launcher) package.
- After receiving callback uri from oauth2 provider, use `getSessionFromUrl` to parse session data.

Persist/restore session:

- No persist storage provided. Users can easily store session as json with any Flutter storage library.
- Expose `recoverSession` method. It's used to recover session from a saved json string.
