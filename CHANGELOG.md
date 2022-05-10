## [0.2.2]
- fix: `OpenIDConnectCredentials`'s `nonce` parameter optional

## [0.2.1]

- fix: Retry access token refresh when offline ([#63](https://github.com/supabase-community/gotrue-dart/pull/63))
- feat: Can add custom http client([#69](https://github.com/supabase-community/gotrue-dart/pull/69))
- feat: Show statuscode in GotrueResponse([#69](https://github.com/supabase-community/gotrue-dart/pull/69))

## [0.2.0]

- BREAKING: `user` will be returned when signing up with auto confirm off ([#63](https://github.com/supabase-community/gotrue-dart/pull/63))
- feat: Slack and Shopify as login providers([43](https://github.com/supabase-community/gotrue-dart/pull/43))
- fix: Adds missing keys - phone, phone_confirmed_at, emailed_confirmed_at to User.toJson()([43](https://github.com/supabase-community/gotrue-dart/pull/43))

## [0.1.6]

- fix: fetch the user, if missing, on `/verify` ([#29](https://github.com/supabase-community/gotrue-dart/issues/29))
- feat: add JWT headers when refreshing token ([#53](https://github.com/supabase-community/gotrue-dart/pull/53))
- feat: add `signInWithOpenIDConnect` ([#61](https://github.com/supabase-community/gotrue-dart/pull/61))

## [0.1.5]

- feat: add `toString` method to `GotrueError`class

## [0.1.4]

- fix: trigger signedIn event on recoverSession

## [0.1.3]

- feat: add `tokenRefreshed` auth event
- feat: add slack, spotify and twitch Auth providers
- fix: update currentSession.user when GoTrueClient.update is called
- chore: export missing types

## [0.1.2]

- feat: `setAuth()` method for setting the session with a provided jwt
- fix: improve client tests

## [0.1.1]

- chore: add `X-Client-Info` header

## [0.1.0]

- feat: add support for phone auth

## [0.0.7]

- fix: stop refreshToken timer on session removed
- fix: close http.Client on request done
- chore: update External OAuth Providers
- chore: add example code block

## [0.0.6]

- fix: export gotrue_response classes

## [0.0.5]

- BREAKING CHANGE: rename 'ProviderOptions' to 'AuthOptions'
- feat: support redirectTo option
- fix: handle jwt expiry less than 60 seconds

## [0.0.4]

- fix: session refresh timer

## [0.0.3]

- fix: wrong timestamp value

## [0.0.2]

- fix: persistSessionString with wrong expiresAt

## [0.0.1]

- fix: URL encode redirectTo

## [0.0.1-dev.11]

- fix: parsing provider callback url with fragment #12

## [0.0.1-dev.10]

- fix: parses provider token and adds oauth scopes and redirectTo
- fix: expiresAt conversion to int and getUser resolving JSON
- fix: signOut method

## [0.0.1-dev.9]

- fix: User nullable params
- fix: Session nullable params
- fix: lint errors

## [0.0.1-dev.8]

- chore: Migrate to Null Safety

## [0.0.1-dev.7]

- fix: Password and other attributes defaulting to email field.
- chore: export UserAttributes

## [0.0.1-dev.6]

- chore: export Provider class

## [0.0.1-dev.5]

- fix: updateUser bug
- fix: http success statusCode check
- fix: stateChangeEmitters uninitialized value

## [0.0.1-dev.4]

- fix: email verification required on sign up

## [0.0.1-dev.3]

- chore: export Session and User classes

## [0.0.1-dev.2]

- fix: session and user parsing from json
- chore: method to get persistSessionString

## [0.0.1-dev.1]

- Initial pre-release.
