CREATE SCHEMA IF NOT EXISTS auth AUTHORIZATION postgres;
GRANT ALL PRIVILEGES ON SCHEMA auth TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auth TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA auth TO postgres;
ALTER USER postgres
SET search_path = "auth";
BEGIN;
SET LOCAL check_function_bodies TO FALSE;
-- Tables have not been created yet
create OR REPLACE function auth.reset_and_init_auth_data() returns void language sql security definer as $$
DELETE FROM auth.users;
DELETE FROM auth.mfa_amr_claims;
DELETE FROM auth.mfa_challenges;
DELETE FROM auth.mfa_factors;
DELETE FROM auth.sessions;
DELETE FROM auth.refresh_tokens;
INSERT INTO auth.users (
        instance_id,
        id,
        email,
        aud,
        role,
        encrypted_password,
        email_confirmed_at,
        last_sign_in_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        recovery_token,
        email_change_token_new,
        email_change
    )
VALUES (
        '00000000-0000-0000-0000-000000000000',
        '18bc7a4e-c095-4573-93dc-e0be29bada97',
        'fake1@email.com',
        '',
        '',
        '$2a$10$fOz84O1J.eztX.VzugMBteSCiLv4GnrzZJgoC4aJMvMPqCI.15vR2',
        '2023-01-02 08:32:24.940663+00',
        '2023-01-02 08:32:24.940663+00',
        '{"provider": "email", "providers": ["email"]}',
        '{}',
        '2023-01-02 08:32:24.940663+00',
        '2023-01-02 08:32:24.940663+00',
        '',
        '',
        '',
        ''
    );
INSERT INTO auth.identities (
        id,
        user_id,
        identity_data,
        provider,
        last_sign_in_at,
        created_at,
        updated_at
    )
VALUES (
        '18bc7a4e-c095-4573-93dc-e0be29bada97',
        '18bc7a4e-c095-4573-93dc-e0be29bada97',
        '{"sub": "18bc7a4e-c095-4573-93dc-e0be29bada97", "email": "fake1@email.com"}',
        'email',
        '2023-01-02 08:32:24.940663+00',
        '2023-01-02 08:32:24.940663+00',
        '2023-01-02 08:32:24.940663+00'
    );
INSERT INTO mfa_factors (
        id,
        user_id,
        friendly_name,
        factor_type,
        status,
        created_at,
        updated_at,
        secret
    )
VALUES (
        '0d3aa138-da96-4aea-8217-af07daa6b82d',
        '18bc7a4e-c095-4573-93dc-e0be29bada97',
        'MyFriendlyName',
        'totp',
        'unverified',
        now(),
        now(),
        'R7K3TR4HN5XBOCDWHGGUGI2YYGQSCLUS'
    );
-- RAISE EXCEPTION 'TEST NOTICE %', select current_setting('request.headers', true);
INSERT INTO mfa_challenges (id, factor_id, created_at, ip_address)
VALUES (
        'b824ca10-cc13-4250-adba-20ee6e5e7dcd',
        '0d3aa138-da96-4aea-8217-af07daa6b82d',
        now(),
        COALESCE(
            (SPLIT_PART(current_setting('request.headers', true)::json->>'x-forwarded-for',',',1))::inet,
            '192.168.96.1'::inet
        )
    );
$$;
COMMIT;

create or replace function auth.test() returns json language sql as $$
select current_setting('request.headers',true)::json;
$$;