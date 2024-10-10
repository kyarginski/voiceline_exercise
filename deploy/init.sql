--
-- PostgreSQL database dump
--

-- Dumped from database version 15.0 (Debian 15.0-1.pgdg110+1)
-- Dumped by pg_dump version 15.0

-- Started on 2022-10-22 20:27:55

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE keycloak;
--
-- TOC entry 4217 (class 1262 OID 16384)
-- Name: keycloak; Type: DATABASE; Schema: -; Owner: keycloak
--

CREATE DATABASE keycloak WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE keycloak OWNER TO keycloak;

\connect keycloak

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 4218 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

create table public.databasechangeloglock
(
    id          integer not null
        primary key,
    locked      boolean not null,
    lockgranted timestamp,
    lockedby    varchar(255)
);

alter table public.databasechangeloglock
    owner to keycloak;

create table public.databasechangelog
(
    id            varchar(255) not null,
    author        varchar(255) not null,
    filename      varchar(255) not null,
    dateexecuted  timestamp    not null,
    orderexecuted integer      not null,
    exectype      varchar(10)  not null,
    md5sum        varchar(35),
    description   varchar(255),
    comments      varchar(255),
    tag           varchar(255),
    liquibase     varchar(20),
    contexts      varchar(255),
    labels        varchar(255),
    deployment_id varchar(10)
);

alter table public.databasechangelog
    owner to keycloak;

create table public.client
(
    id                           varchar(36)           not null
        constraint constraint_7
            primary key,
    enabled                      boolean default false not null,
    full_scope_allowed           boolean default false not null,
    client_id                    varchar(255),
    not_before                   integer,
    public_client                boolean default false not null,
    secret                       varchar(255),
    base_url                     varchar(255),
    bearer_only                  boolean default false not null,
    management_url               varchar(255),
    surrogate_auth_required      boolean default false not null,
    realm_id                     varchar(36),
    protocol                     varchar(255),
    node_rereg_timeout           integer default 0,
    frontchannel_logout          boolean default false not null,
    consent_required             boolean default false not null,
    name                         varchar(255),
    service_accounts_enabled     boolean default false not null,
    client_authenticator_type    varchar(255),
    root_url                     varchar(255),
    description                  varchar(255),
    registration_token           varchar(255),
    standard_flow_enabled        boolean default true  not null,
    implicit_flow_enabled        boolean default false not null,
    direct_access_grants_enabled boolean default false not null,
    always_display_in_console    boolean default false not null,
    constraint uk_b71cjlbenv945rb6gcon438at
        unique (realm_id, client_id)
);

alter table public.client
    owner to keycloak;

create index idx_client_id
    on public.client (client_id);

create table public.event_entity
(
    id                      varchar(36) not null
        constraint constraint_4
            primary key,
    client_id               varchar(255),
    details_json            varchar(2550),
    error                   varchar(255),
    ip_address              varchar(255),
    realm_id                varchar(255),
    session_id              varchar(255),
    event_time              bigint,
    type                    varchar(255),
    user_id                 varchar(255),
    details_json_long_value text
);

alter table public.event_entity
    owner to keycloak;

create index idx_event_time
    on public.event_entity (realm_id, event_time);

create table public.realm
(
    id                           varchar(36)               not null
        constraint constraint_4a
            primary key,
    access_code_lifespan         integer,
    user_action_lifespan         integer,
    access_token_lifespan        integer,
    account_theme                varchar(255),
    admin_theme                  varchar(255),
    email_theme                  varchar(255),
    enabled                      boolean     default false not null,
    events_enabled               boolean     default false not null,
    events_expiration            bigint,
    login_theme                  varchar(255),
    name                         varchar(255)
        constraint uk_orvsdmla56612eaefiq6wl5oi
            unique,
    not_before                   integer,
    password_policy              varchar(2550),
    registration_allowed         boolean     default false not null,
    remember_me                  boolean     default false not null,
    reset_password_allowed       boolean     default false not null,
    social                       boolean     default false not null,
    ssl_required                 varchar(255),
    sso_idle_timeout             integer,
    sso_max_lifespan             integer,
    update_profile_on_soc_login  boolean     default false not null,
    verify_email                 boolean     default false not null,
    master_admin_client          varchar(36),
    login_lifespan               integer,
    internationalization_enabled boolean     default false not null,
    default_locale               varchar(255),
    reg_email_as_username        boolean     default false not null,
    admin_events_enabled         boolean     default false not null,
    admin_events_details_enabled boolean     default false not null,
    edit_username_allowed        boolean     default false not null,
    otp_policy_counter           integer     default 0,
    otp_policy_window            integer     default 1,
    otp_policy_period            integer     default 30,
    otp_policy_digits            integer     default 6,
    otp_policy_alg               varchar(36) default 'HmacSHA1'::character varying,
    otp_policy_type              varchar(36) default 'totp'::character varying,
    browser_flow                 varchar(36),
    registration_flow            varchar(36),
    direct_grant_flow            varchar(36),
    reset_credentials_flow       varchar(36),
    client_auth_flow             varchar(36),
    offline_session_idle_timeout integer     default 0,
    revoke_refresh_token         boolean     default false not null,
    access_token_life_implicit   integer     default 0,
    login_with_email_allowed     boolean     default true  not null,
    duplicate_emails_allowed     boolean     default false not null,
    docker_auth_flow             varchar(36),
    refresh_token_max_reuse      integer     default 0,
    allow_user_managed_access    boolean     default false not null,
    sso_max_lifespan_remember_me integer     default 0     not null,
    sso_idle_timeout_remember_me integer     default 0     not null,
    default_role                 varchar(255)
);

alter table public.realm
    owner to keycloak;

create table public.keycloak_role
(
    id                      varchar(36)           not null
        constraint constraint_a
            primary key,
    client_realm_constraint varchar(255),
    client_role             boolean default false not null,
    description             varchar(255),
    name                    varchar(255),
    realm_id                varchar(255),
    client                  varchar(36),
    realm                   varchar(36)
        constraint fk_6vyqfe4cn4wlq8r6kt5vdsj5c
            references public.realm,
    constraint "UK_J3RWUVD56ONTGSUHOGM184WW2-2"
        unique (name, client_realm_constraint)
);

alter table public.keycloak_role
    owner to keycloak;

create table public.composite_role
(
    composite  varchar(36) not null
        constraint fk_a63wvekftu8jo1pnj81e7mce2
            references public.keycloak_role,
    child_role varchar(36) not null
        constraint fk_gr7thllb9lu8q4vqa4524jjy8
            references public.keycloak_role,
    constraint constraint_composite_role
        primary key (composite, child_role)
);

alter table public.composite_role
    owner to keycloak;

create index idx_composite
    on public.composite_role (composite);

create index idx_composite_child
    on public.composite_role (child_role);

create index idx_keycloak_role_client
    on public.keycloak_role (client);

create index idx_keycloak_role_realm
    on public.keycloak_role (realm);

create index idx_realm_master_adm_cli
    on public.realm (master_admin_client);

create table public.realm_attribute
(
    name     varchar(255) not null,
    realm_id varchar(36)  not null
        constraint fk_8shxd6l3e9atqukacxgpffptw
            references public.realm,
    value    text,
    constraint constraint_9
        primary key (name, realm_id)
);

alter table public.realm_attribute
    owner to keycloak;

create index idx_realm_attr_realm
    on public.realm_attribute (realm_id);

create table public.realm_events_listeners
(
    realm_id varchar(36)  not null
        constraint fk_h846o4h0w8epx5nxev9f5y69j
            references public.realm,
    value    varchar(255) not null,
    constraint constr_realm_events_listeners
        primary key (realm_id, value)
);

alter table public.realm_events_listeners
    owner to keycloak;

create index idx_realm_evt_list_realm
    on public.realm_events_listeners (realm_id);

create table public.realm_required_credential
(
    type       varchar(255)          not null,
    form_label varchar(255),
    input      boolean default false not null,
    secret     boolean default false not null,
    realm_id   varchar(36)           not null
        constraint fk_5hg65lybevavkqfki3kponh9v
            references public.realm,
    constraint constraint_92
        primary key (realm_id, type)
);

alter table public.realm_required_credential
    owner to keycloak;

create table public.realm_smtp_config
(
    realm_id varchar(36)  not null
        constraint fk_70ej8xdxgxd0b9hh6180irr0o
            references public.realm,
    value    varchar(255),
    name     varchar(255) not null,
    constraint constraint_e
        primary key (realm_id, name)
);

alter table public.realm_smtp_config
    owner to keycloak;

create table public.redirect_uris
(
    client_id varchar(36)  not null
        constraint fk_1burs8pb4ouj97h5wuppahv9f
            references public.client,
    value     varchar(255) not null,
    constraint constraint_redirect_uris
        primary key (client_id, value)
);

alter table public.redirect_uris
    owner to keycloak;

create index idx_redir_uri_client
    on public.redirect_uris (client_id);

create table public.scope_mapping
(
    client_id varchar(36) not null
        constraint fk_ouse064plmlr732lxjcn1q5f1
            references public.client,
    role_id   varchar(36) not null,
    constraint constraint_81
        primary key (client_id, role_id)
);

alter table public.scope_mapping
    owner to keycloak;

create index idx_scope_mapping_role
    on public.scope_mapping (role_id);

create table public.username_login_failure
(
    realm_id                varchar(36)  not null,
    username                varchar(255) not null,
    failed_login_not_before integer,
    last_failure            bigint,
    last_ip_failure         varchar(255),
    num_failures            integer,
    constraint "CONSTRAINT_17-2"
        primary key (realm_id, username)
);

alter table public.username_login_failure
    owner to keycloak;

create table public.user_entity
(
    id                          varchar(36)           not null
        constraint constraint_fb
            primary key,
    email                       varchar(255),
    email_constraint            varchar(255),
    email_verified              boolean default false not null,
    enabled                     boolean default false not null,
    federation_link             varchar(255),
    first_name                  varchar(255),
    last_name                   varchar(255),
    realm_id                    varchar(255),
    username                    varchar(255),
    created_timestamp           bigint,
    service_account_client_link varchar(255),
    not_before                  integer default 0     not null,
    constraint uk_dykn684sl8up1crfei6eckhd7
        unique (realm_id, email_constraint),
    constraint uk_ru8tt6t700s9v50bu18ws5ha6
        unique (realm_id, username)
);

alter table public.user_entity
    owner to keycloak;

create table public.credential
(
    id              varchar(36) not null
        constraint constraint_f
            primary key,
    salt            bytea,
    type            varchar(255),
    user_id         varchar(36)
        constraint fk_pfyr0glasqyl0dei3kl69r6v0
            references public.user_entity,
    created_date    bigint,
    user_label      varchar(255),
    secret_data     text,
    credential_data text,
    priority        integer
);

alter table public.credential
    owner to keycloak;

create index idx_user_credential
    on public.credential (user_id);

create table public.user_attribute
(
    name                       varchar(255)                                                         not null,
    value                      varchar(255),
    user_id                    varchar(36)                                                          not null
        constraint fk_5hrm2vlf9ql5fu043kqepovbr
            references public.user_entity,
    id                         varchar(36) default 'sybase-needs-something-here'::character varying not null
        constraint constraint_user_attribute_pk
            primary key,
    long_value_hash            bytea,
    long_value_hash_lower_case bytea,
    long_value                 text
);

alter table public.user_attribute
    owner to keycloak;

create index idx_user_attribute
    on public.user_attribute (user_id);

create index idx_user_attribute_name
    on public.user_attribute (name, value);

create index user_attr_long_values
    on public.user_attribute (long_value_hash, name);

create index user_attr_long_values_lower_case
    on public.user_attribute (long_value_hash_lower_case, name);

create index idx_user_email
    on public.user_entity (email);

create index idx_user_service_account
    on public.user_entity (realm_id, service_account_client_link);

create table public.user_federation_provider
(
    id                  varchar(36) not null
        constraint constraint_5c
            primary key,
    changed_sync_period integer,
    display_name        varchar(255),
    full_sync_period    integer,
    last_sync           integer,
    priority            integer,
    provider_name       varchar(255),
    realm_id            varchar(36)
        constraint fk_1fj32f6ptolw2qy60cd8n01e8
            references public.realm
);

alter table public.user_federation_provider
    owner to keycloak;

create table public.user_federation_config
(
    user_federation_provider_id varchar(36)  not null
        constraint fk_t13hpu1j94r2ebpekr39x5eu5
            references public.user_federation_provider,
    value                       varchar(255),
    name                        varchar(255) not null,
    constraint constraint_f9
        primary key (user_federation_provider_id, name)
);

alter table public.user_federation_config
    owner to keycloak;

create index idx_usr_fed_prv_realm
    on public.user_federation_provider (realm_id);

create table public.user_required_action
(
    user_id         varchar(36)                                 not null
        constraint fk_6qj3w1jw9cvafhe19bwsiuvmd
            references public.user_entity,
    required_action varchar(255) default ' '::character varying not null,
    constraint constraint_required_action
        primary key (required_action, user_id)
);

alter table public.user_required_action
    owner to keycloak;

create index idx_user_reqactions
    on public.user_required_action (user_id);

create table public.user_role_mapping
(
    role_id varchar(255) not null,
    user_id varchar(36)  not null
        constraint fk_c4fqv34p1mbylloxang7b1q3l
            references public.user_entity,
    constraint constraint_c
        primary key (role_id, user_id)
);

alter table public.user_role_mapping
    owner to keycloak;

create index idx_user_role_mapping
    on public.user_role_mapping (user_id);

create table public.web_origins
(
    client_id varchar(36)  not null
        constraint fk_lojpho213xcx4wnkog82ssrfy
            references public.client,
    value     varchar(255) not null,
    constraint constraint_web_origins
        primary key (client_id, value)
);

alter table public.web_origins
    owner to keycloak;

create index idx_web_orig_client
    on public.web_origins (client_id);

create table public.client_attributes
(
    client_id varchar(36)  not null
        constraint fk3c47c64beacca966
            references public.client,
    name      varchar(255) not null,
    value     text,
    constraint constraint_3c
        primary key (client_id, name)
);

alter table public.client_attributes
    owner to keycloak;

create index idx_client_att_by_name_value
    on public.client_attributes (name, substr(value, 1, 255));

create table public.client_node_registrations
(
    client_id varchar(36)  not null
        constraint fk4129723ba992f594
            references public.client,
    value     integer,
    name      varchar(255) not null,
    constraint constraint_84
        primary key (client_id, name)
);

alter table public.client_node_registrations
    owner to keycloak;

create table public.federated_identity
(
    identity_provider  varchar(255) not null,
    realm_id           varchar(36),
    federated_user_id  varchar(255),
    federated_username varchar(255),
    token              text,
    user_id            varchar(36)  not null
        constraint fk404288b92ef007a6
            references public.user_entity,
    constraint constraint_40
        primary key (identity_provider, user_id)
);

alter table public.federated_identity
    owner to keycloak;

create index idx_fedidentity_user
    on public.federated_identity (user_id);

create index idx_fedidentity_feduser
    on public.federated_identity (federated_user_id);

create table public.identity_provider
(
    internal_id                varchar(36)           not null
        constraint constraint_2b
            primary key,
    enabled                    boolean default false not null,
    provider_alias             varchar(255),
    provider_id                varchar(255),
    store_token                boolean default false not null,
    authenticate_by_default    boolean default false not null,
    realm_id                   varchar(36)
        constraint fk2b4ebc52ae5c3b34
            references public.realm,
    add_token_role             boolean default true  not null,
    trust_email                boolean default false not null,
    first_broker_login_flow_id varchar(36),
    post_broker_login_flow_id  varchar(36),
    provider_display_name      varchar(255),
    link_only                  boolean default false not null,
    organization_id            varchar(255),
    hide_on_login              boolean default false,
    constraint uk_2daelwnibji49avxsrtuf6xj33
        unique (provider_alias, realm_id)
);

alter table public.identity_provider
    owner to keycloak;

create index idx_ident_prov_realm
    on public.identity_provider (realm_id);

create index idx_idp_realm_org
    on public.identity_provider (realm_id, organization_id);

create index idx_idp_for_login
    on public.identity_provider (realm_id, enabled, link_only, hide_on_login, organization_id);

create table public.identity_provider_config
(
    identity_provider_id varchar(36)  not null
        constraint fkdc4897cf864c4e43
            references public.identity_provider,
    value                text,
    name                 varchar(255) not null,
    constraint constraint_d
        primary key (identity_provider_id, name)
);

alter table public.identity_provider_config
    owner to keycloak;

create table public.realm_supported_locales
(
    realm_id varchar(36)  not null
        constraint fk_supported_locales_realm
            references public.realm,
    value    varchar(255) not null,
    constraint constr_realm_supported_locales
        primary key (realm_id, value)
);

alter table public.realm_supported_locales
    owner to keycloak;

create index idx_realm_supp_local_realm
    on public.realm_supported_locales (realm_id);

create table public.realm_enabled_event_types
(
    realm_id varchar(36)  not null
        constraint fk_h846o4h0w8epx5nwedrf5y69j
            references public.realm,
    value    varchar(255) not null,
    constraint constr_realm_enabl_event_types
        primary key (realm_id, value)
);

alter table public.realm_enabled_event_types
    owner to keycloak;

create index idx_realm_evt_types_realm
    on public.realm_enabled_event_types (realm_id);

create table public.migration_model
(
    id          varchar(36)      not null
        constraint constraint_migmod
            primary key,
    version     varchar(36),
    update_time bigint default 0 not null
);

alter table public.migration_model
    owner to keycloak;

create index idx_update_time
    on public.migration_model (update_time);

create table public.identity_provider_mapper
(
    id              varchar(36)  not null
        constraint constraint_idpm
            primary key,
    name            varchar(255) not null,
    idp_alias       varchar(255) not null,
    idp_mapper_name varchar(255) not null,
    realm_id        varchar(36)  not null
        constraint fk_idpm_realm
            references public.realm
);

alter table public.identity_provider_mapper
    owner to keycloak;

create index idx_id_prov_mapp_realm
    on public.identity_provider_mapper (realm_id);

create table public.idp_mapper_config
(
    idp_mapper_id varchar(36)  not null
        constraint fk_idpmconfig
            references public.identity_provider_mapper,
    value         text,
    name          varchar(255) not null,
    constraint constraint_idpmconfig
        primary key (idp_mapper_id, name)
);

alter table public.idp_mapper_config
    owner to keycloak;

create table public.user_consent
(
    id                      varchar(36) not null
        constraint constraint_grntcsnt_pm
            primary key,
    client_id               varchar(255),
    user_id                 varchar(36) not null
        constraint fk_grntcsnt_user
            references public.user_entity,
    created_date            bigint,
    last_updated_date       bigint,
    client_storage_provider varchar(36),
    external_client_id      varchar(255),
    constraint uk_local_consent
        unique (client_id, user_id),
    constraint uk_external_consent
        unique (client_storage_provider, external_client_id, user_id)
);

alter table public.user_consent
    owner to keycloak;

create index idx_user_consent
    on public.user_consent (user_id);

create table public.admin_event_entity
(
    id               varchar(36) not null
        constraint constraint_admin_event_entity
            primary key,
    admin_event_time bigint,
    realm_id         varchar(255),
    operation_type   varchar(255),
    auth_realm_id    varchar(255),
    auth_client_id   varchar(255),
    auth_user_id     varchar(255),
    ip_address       varchar(255),
    resource_path    varchar(2550),
    representation   text,
    error            varchar(255),
    resource_type    varchar(64)
);

alter table public.admin_event_entity
    owner to keycloak;

create index idx_admin_event_time
    on public.admin_event_entity (realm_id, admin_event_time);

create table public.authenticator_config
(
    id       varchar(36) not null
        constraint constraint_auth_pk
            primary key,
    alias    varchar(255),
    realm_id varchar(36)
        constraint fk_auth_realm
            references public.realm
);

alter table public.authenticator_config
    owner to keycloak;

create index idx_auth_config_realm
    on public.authenticator_config (realm_id);

create table public.authentication_flow
(
    id          varchar(36)                                         not null
        constraint constraint_auth_flow_pk
            primary key,
    alias       varchar(255),
    description varchar(255),
    realm_id    varchar(36)
        constraint fk_auth_flow_realm
            references public.realm,
    provider_id varchar(36) default 'basic-flow'::character varying not null,
    top_level   boolean     default false                           not null,
    built_in    boolean     default false                           not null
);

alter table public.authentication_flow
    owner to keycloak;

create index idx_auth_flow_realm
    on public.authentication_flow (realm_id);

create table public.authentication_execution
(
    id                 varchar(36)           not null
        constraint constraint_auth_exec_pk
            primary key,
    alias              varchar(255),
    authenticator      varchar(36),
    realm_id           varchar(36)
        constraint fk_auth_exec_realm
            references public.realm,
    flow_id            varchar(36)
        constraint fk_auth_exec_flow
            references public.authentication_flow,
    requirement        integer,
    priority           integer,
    authenticator_flow boolean default false not null,
    auth_flow_id       varchar(36),
    auth_config        varchar(36)
);

alter table public.authentication_execution
    owner to keycloak;

create index idx_auth_exec_realm_flow
    on public.authentication_execution (realm_id, flow_id);

create index idx_auth_exec_flow
    on public.authentication_execution (flow_id);

create table public.authenticator_config_entry
(
    authenticator_id varchar(36)  not null,
    value            text,
    name             varchar(255) not null,
    constraint constraint_auth_cfg_pk
        primary key (authenticator_id, name)
);

alter table public.authenticator_config_entry
    owner to keycloak;

create table public.user_federation_mapper
(
    id                     varchar(36)  not null
        constraint constraint_fedmapperpm
            primary key,
    name                   varchar(255) not null,
    federation_provider_id varchar(36)  not null
        constraint fk_fedmapperpm_fedprv
            references public.user_federation_provider,
    federation_mapper_type varchar(255) not null,
    realm_id               varchar(36)  not null
        constraint fk_fedmapperpm_realm
            references public.realm
);

alter table public.user_federation_mapper
    owner to keycloak;

create index idx_usr_fed_map_fed_prv
    on public.user_federation_mapper (federation_provider_id);

create index idx_usr_fed_map_realm
    on public.user_federation_mapper (realm_id);

create table public.user_federation_mapper_config
(
    user_federation_mapper_id varchar(36)  not null
        constraint fk_fedmapper_cfg
            references public.user_federation_mapper,
    value                     varchar(255),
    name                      varchar(255) not null,
    constraint constraint_fedmapper_cfg_pm
        primary key (user_federation_mapper_id, name)
);

alter table public.user_federation_mapper_config
    owner to keycloak;

create table public.required_action_provider
(
    id             varchar(36)           not null
        constraint constraint_req_act_prv_pk
            primary key,
    alias          varchar(255),
    name           varchar(255),
    realm_id       varchar(36)
        constraint fk_req_act_realm
            references public.realm,
    enabled        boolean default false not null,
    default_action boolean default false not null,
    provider_id    varchar(255),
    priority       integer
);

alter table public.required_action_provider
    owner to keycloak;

create index idx_req_act_prov_realm
    on public.required_action_provider (realm_id);

create table public.required_action_config
(
    required_action_id varchar(36)  not null,
    value              text,
    name               varchar(255) not null,
    constraint constraint_req_act_cfg_pk
        primary key (required_action_id, name)
);

alter table public.required_action_config
    owner to keycloak;

create table public.offline_user_session
(
    user_session_id      varchar(36)       not null,
    user_id              varchar(255)      not null,
    realm_id             varchar(36)       not null,
    created_on           integer           not null,
    offline_flag         varchar(4)        not null,
    data                 text,
    last_session_refresh integer default 0 not null,
    broker_session_id    varchar(1024),
    version              integer default 0,
    constraint constraint_offl_us_ses_pk2
        primary key (user_session_id, offline_flag)
);

alter table public.offline_user_session
    owner to keycloak;

create index idx_offline_uss_by_user
    on public.offline_user_session (user_id, realm_id, offline_flag);

create index idx_offline_uss_by_last_session_refresh
    on public.offline_user_session (realm_id, offline_flag, last_session_refresh);

create index idx_offline_uss_by_broker_session_id
    on public.offline_user_session (broker_session_id, realm_id);

create table public.offline_client_session
(
    user_session_id         varchar(36)                                     not null,
    client_id               varchar(255)                                    not null,
    offline_flag            varchar(4)                                      not null,
    timestamp               integer,
    data                    text,
    client_storage_provider varchar(36)  default 'local'::character varying not null,
    external_client_id      varchar(255) default 'local'::character varying not null,
    version                 integer      default 0,
    constraint constraint_offl_cl_ses_pk3
        primary key (user_session_id, client_id, client_storage_provider, external_client_id, offline_flag)
);

alter table public.offline_client_session
    owner to keycloak;

create table public.keycloak_group
(
    id           varchar(36)       not null
        constraint constraint_group
            primary key,
    name         varchar(255),
    parent_group varchar(36)       not null,
    realm_id     varchar(36),
    type         integer default 0 not null,
    constraint sibling_names
        unique (realm_id, parent_group, name)
);

alter table public.keycloak_group
    owner to keycloak;

create table public.group_role_mapping
(
    role_id  varchar(36) not null,
    group_id varchar(36) not null
        constraint fk_group_role_group
            references public.keycloak_group,
    constraint constraint_group_role
        primary key (role_id, group_id)
);

alter table public.group_role_mapping
    owner to keycloak;

create index idx_group_role_mapp_group
    on public.group_role_mapping (group_id);

create table public.group_attribute
(
    id       varchar(36) default 'sybase-needs-something-here'::character varying not null
        constraint constraint_group_attribute_pk
            primary key,
    name     varchar(255)                                                         not null,
    value    varchar(255),
    group_id varchar(36)                                                          not null
        constraint fk_group_attribute_group
            references public.keycloak_group
);

alter table public.group_attribute
    owner to keycloak;

create index idx_group_attr_group
    on public.group_attribute (group_id);

create index idx_group_att_by_name_value
    on public.group_attribute (name, (value::character varying(250)));

create table public.user_group_membership
(
    group_id        varchar(36)  not null,
    user_id         varchar(36)  not null
        constraint fk_user_group_user
            references public.user_entity,
    membership_type varchar(255) not null,
    constraint constraint_user_group
        primary key (group_id, user_id)
);

alter table public.user_group_membership
    owner to keycloak;

create index idx_user_group_mapping
    on public.user_group_membership (user_id);

create table public.realm_default_groups
(
    realm_id varchar(36) not null
        constraint fk_def_groups_realm
            references public.realm,
    group_id varchar(36) not null
        constraint con_group_id_def_groups
            unique,
    constraint constr_realm_default_groups
        primary key (realm_id, group_id)
);

alter table public.realm_default_groups
    owner to keycloak;

create index idx_realm_def_grp_realm
    on public.realm_default_groups (realm_id);

create table public.client_scope
(
    id          varchar(36) not null
        constraint pk_cli_template
            primary key,
    name        varchar(255),
    realm_id    varchar(36),
    description varchar(255),
    protocol    varchar(255),
    constraint uk_cli_scope
        unique (realm_id, name)
);

alter table public.client_scope
    owner to keycloak;

create table public.protocol_mapper
(
    id                   varchar(36)  not null
        constraint constraint_pcm
            primary key,
    name                 varchar(255) not null,
    protocol             varchar(255) not null,
    protocol_mapper_name varchar(255) not null,
    client_id            varchar(36)
        constraint fk_pcm_realm
            references public.client,
    client_scope_id      varchar(36)
        constraint fk_cli_scope_mapper
            references public.client_scope
);

alter table public.protocol_mapper
    owner to keycloak;

create index idx_protocol_mapper_client
    on public.protocol_mapper (client_id);

create index idx_clscope_protmap
    on public.protocol_mapper (client_scope_id);

create table public.protocol_mapper_config
(
    protocol_mapper_id varchar(36)  not null
        constraint fk_pmconfig
            references public.protocol_mapper,
    value              text,
    name               varchar(255) not null,
    constraint constraint_pmconfig
        primary key (protocol_mapper_id, name)
);

alter table public.protocol_mapper_config
    owner to keycloak;

create index idx_realm_clscope
    on public.client_scope (realm_id);

create table public.client_scope_attributes
(
    scope_id varchar(36)  not null
        constraint fk_cl_scope_attr_scope
            references public.client_scope,
    value    varchar(2048),
    name     varchar(255) not null,
    constraint pk_cl_tmpl_attr
        primary key (scope_id, name)
);

alter table public.client_scope_attributes
    owner to keycloak;

create index idx_clscope_attrs
    on public.client_scope_attributes (scope_id);

create table public.client_scope_role_mapping
(
    scope_id varchar(36) not null
        constraint fk_cl_scope_rm_scope
            references public.client_scope,
    role_id  varchar(36) not null,
    constraint pk_template_scope
        primary key (scope_id, role_id)
);

alter table public.client_scope_role_mapping
    owner to keycloak;

create index idx_clscope_role
    on public.client_scope_role_mapping (scope_id);

create index idx_role_clscope
    on public.client_scope_role_mapping (role_id);

create table public.resource_server
(
    id                   varchar(36)            not null
        constraint pk_resource_server
            primary key,
    allow_rs_remote_mgmt boolean  default false not null,
    policy_enforce_mode  smallint               not null,
    decision_strategy    smallint default 1     not null
);

alter table public.resource_server
    owner to keycloak;

create table public.resource_server_resource
(
    id                   varchar(36)           not null
        constraint constraint_farsr
            primary key,
    name                 varchar(255)          not null,
    type                 varchar(255),
    icon_uri             varchar(255),
    owner                varchar(255)          not null,
    resource_server_id   varchar(36)           not null
        constraint fk_frsrho213xcx4wnkog82ssrfy
            references public.resource_server,
    owner_managed_access boolean default false not null,
    display_name         varchar(255),
    constraint uk_frsr6t700s9v50bu18ws5ha6
        unique (name, owner, resource_server_id)
);

alter table public.resource_server_resource
    owner to keycloak;

create index idx_res_srv_res_res_srv
    on public.resource_server_resource (resource_server_id);

create table public.resource_server_scope
(
    id                 varchar(36)  not null
        constraint constraint_farsrs
            primary key,
    name               varchar(255) not null,
    icon_uri           varchar(255),
    resource_server_id varchar(36)  not null
        constraint fk_frsrso213xcx4wnkog82ssrfy
            references public.resource_server,
    display_name       varchar(255),
    constraint uk_frsrst700s9v50bu18ws5ha6
        unique (name, resource_server_id)
);

alter table public.resource_server_scope
    owner to keycloak;

create index idx_res_srv_scope_res_srv
    on public.resource_server_scope (resource_server_id);

create table public.resource_server_policy
(
    id                 varchar(36)  not null
        constraint constraint_farsrp
            primary key,
    name               varchar(255) not null,
    description        varchar(255),
    type               varchar(255) not null,
    decision_strategy  smallint,
    logic              smallint,
    resource_server_id varchar(36)  not null
        constraint fk_frsrpo213xcx4wnkog82ssrfy
            references public.resource_server,
    owner              varchar(255),
    constraint uk_frsrpt700s9v50bu18ws5ha6
        unique (name, resource_server_id)
);

alter table public.resource_server_policy
    owner to keycloak;

create index idx_res_serv_pol_res_serv
    on public.resource_server_policy (resource_server_id);

create table public.policy_config
(
    policy_id varchar(36)  not null
        constraint fkdc34197cf864c4e43
            references public.resource_server_policy,
    name      varchar(255) not null,
    value     text,
    constraint constraint_dpc
        primary key (policy_id, name)
);

alter table public.policy_config
    owner to keycloak;

create table public.resource_scope
(
    resource_id varchar(36) not null
        constraint fk_frsrpos13xcx4wnkog82ssrfy
            references public.resource_server_resource,
    scope_id    varchar(36) not null
        constraint fk_frsrps213xcx4wnkog82ssrfy
            references public.resource_server_scope,
    constraint constraint_farsrsp
        primary key (resource_id, scope_id)
);

alter table public.resource_scope
    owner to keycloak;

create index idx_res_scope_scope
    on public.resource_scope (scope_id);

create table public.resource_policy
(
    resource_id varchar(36) not null
        constraint fk_frsrpos53xcx4wnkog82ssrfy
            references public.resource_server_resource,
    policy_id   varchar(36) not null
        constraint fk_frsrpp213xcx4wnkog82ssrfy
            references public.resource_server_policy,
    constraint constraint_farsrpp
        primary key (resource_id, policy_id)
);

alter table public.resource_policy
    owner to keycloak;

create index idx_res_policy_policy
    on public.resource_policy (policy_id);

create table public.scope_policy
(
    scope_id  varchar(36) not null
        constraint fk_frsrpass3xcx4wnkog82ssrfy
            references public.resource_server_scope,
    policy_id varchar(36) not null
        constraint fk_frsrasp13xcx4wnkog82ssrfy
            references public.resource_server_policy,
    constraint constraint_farsrsps
        primary key (scope_id, policy_id)
);

alter table public.scope_policy
    owner to keycloak;

create index idx_scope_policy_policy
    on public.scope_policy (policy_id);

create table public.associated_policy
(
    policy_id            varchar(36) not null
        constraint fk_frsrpas14xcx4wnkog82ssrfy
            references public.resource_server_policy,
    associated_policy_id varchar(36) not null
        constraint fk_frsr5s213xcx4wnkog82ssrfy
            references public.resource_server_policy,
    constraint constraint_farsrpap
        primary key (policy_id, associated_policy_id)
);

alter table public.associated_policy
    owner to keycloak;

create index idx_assoc_pol_assoc_pol_id
    on public.associated_policy (associated_policy_id);

create table public.broker_link
(
    identity_provider   varchar(255) not null,
    storage_provider_id varchar(255),
    realm_id            varchar(36)  not null,
    broker_user_id      varchar(255),
    broker_username     varchar(255),
    token               text,
    user_id             varchar(255) not null,
    constraint constr_broker_link_pk
        primary key (identity_provider, user_id)
);

alter table public.broker_link
    owner to keycloak;

create table public.fed_user_attribute
(
    id                         varchar(36)  not null
        constraint constr_fed_user_attr_pk
            primary key,
    name                       varchar(255) not null,
    user_id                    varchar(255) not null,
    realm_id                   varchar(36)  not null,
    storage_provider_id        varchar(36),
    value                      varchar(2024),
    long_value_hash            bytea,
    long_value_hash_lower_case bytea,
    long_value                 text
);

alter table public.fed_user_attribute
    owner to keycloak;

create index idx_fu_attribute
    on public.fed_user_attribute (user_id, realm_id, name);

create index fed_user_attr_long_values
    on public.fed_user_attribute (long_value_hash, name);

create index fed_user_attr_long_values_lower_case
    on public.fed_user_attribute (long_value_hash_lower_case, name);

create table public.fed_user_consent
(
    id                      varchar(36)  not null
        constraint constr_fed_user_consent_pk
            primary key,
    client_id               varchar(255),
    user_id                 varchar(255) not null,
    realm_id                varchar(36)  not null,
    storage_provider_id     varchar(36),
    created_date            bigint,
    last_updated_date       bigint,
    client_storage_provider varchar(36),
    external_client_id      varchar(255)
);

alter table public.fed_user_consent
    owner to keycloak;

create index idx_fu_consent_ru
    on public.fed_user_consent (realm_id, user_id);

create index idx_fu_cnsnt_ext
    on public.fed_user_consent (user_id, client_storage_provider, external_client_id);

create index idx_fu_consent
    on public.fed_user_consent (user_id, client_id);

create table public.fed_user_credential
(
    id                  varchar(36)  not null
        constraint constr_fed_user_cred_pk
            primary key,
    salt                bytea,
    type                varchar(255),
    created_date        bigint,
    user_id             varchar(255) not null,
    realm_id            varchar(36)  not null,
    storage_provider_id varchar(36),
    user_label          varchar(255),
    secret_data         text,
    credential_data     text,
    priority            integer
);

alter table public.fed_user_credential
    owner to keycloak;

create index idx_fu_credential
    on public.fed_user_credential (user_id, type);

create index idx_fu_credential_ru
    on public.fed_user_credential (realm_id, user_id);

create table public.fed_user_group_membership
(
    group_id            varchar(36)  not null,
    user_id             varchar(255) not null,
    realm_id            varchar(36)  not null,
    storage_provider_id varchar(36),
    constraint constr_fed_user_group
        primary key (group_id, user_id)
);

alter table public.fed_user_group_membership
    owner to keycloak;

create index idx_fu_group_membership
    on public.fed_user_group_membership (user_id, group_id);

create index idx_fu_group_membership_ru
    on public.fed_user_group_membership (realm_id, user_id);

create table public.fed_user_required_action
(
    required_action     varchar(255) default ' '::character varying not null,
    user_id             varchar(255)                                not null,
    realm_id            varchar(36)                                 not null,
    storage_provider_id varchar(36),
    constraint constr_fed_required_action
        primary key (required_action, user_id)
);

alter table public.fed_user_required_action
    owner to keycloak;

create index idx_fu_required_action
    on public.fed_user_required_action (user_id, required_action);

create index idx_fu_required_action_ru
    on public.fed_user_required_action (realm_id, user_id);

create table public.fed_user_role_mapping
(
    role_id             varchar(36)  not null,
    user_id             varchar(255) not null,
    realm_id            varchar(36)  not null,
    storage_provider_id varchar(36),
    constraint constr_fed_user_role
        primary key (role_id, user_id)
);

alter table public.fed_user_role_mapping
    owner to keycloak;

create index idx_fu_role_mapping
    on public.fed_user_role_mapping (user_id, role_id);

create index idx_fu_role_mapping_ru
    on public.fed_user_role_mapping (realm_id, user_id);

create table public.component
(
    id            varchar(36) not null
        constraint constr_component_pk
            primary key,
    name          varchar(255),
    parent_id     varchar(36),
    provider_id   varchar(36),
    provider_type varchar(255),
    realm_id      varchar(36)
        constraint fk_component_realm
            references public.realm,
    sub_type      varchar(255)
);

alter table public.component
    owner to keycloak;

create table public.component_config
(
    id           varchar(36)  not null
        constraint constr_component_config_pk
            primary key,
    component_id varchar(36)  not null
        constraint fk_component_config
            references public.component,
    name         varchar(255) not null,
    value        text
);

alter table public.component_config
    owner to keycloak;

create index idx_compo_config_compo
    on public.component_config (component_id);

create index idx_component_realm
    on public.component (realm_id);

create index idx_component_provider_type
    on public.component (provider_type);

create table public.federated_user
(
    id                  varchar(255) not null
        constraint constr_federated_user
            primary key,
    storage_provider_id varchar(255),
    realm_id            varchar(36)  not null
);

alter table public.federated_user
    owner to keycloak;

create table public.client_initial_access
(
    id              varchar(36) not null
        constraint cnstr_client_init_acc_pk
            primary key,
    realm_id        varchar(36) not null
        constraint fk_client_init_acc_realm
            references public.realm,
    timestamp       integer,
    expiration      integer,
    count           integer,
    remaining_count integer
);

alter table public.client_initial_access
    owner to keycloak;

create index idx_client_init_acc_realm
    on public.client_initial_access (realm_id);

create table public.client_auth_flow_bindings
(
    client_id    varchar(36)  not null,
    flow_id      varchar(36),
    binding_name varchar(255) not null,
    constraint c_cli_flow_bind
        primary key (client_id, binding_name)
);

alter table public.client_auth_flow_bindings
    owner to keycloak;

create table public.client_scope_client
(
    client_id     varchar(255)          not null,
    scope_id      varchar(255)          not null,
    default_scope boolean default false not null,
    constraint c_cli_scope_bind
        primary key (client_id, scope_id)
);

alter table public.client_scope_client
    owner to keycloak;

create index idx_clscope_cl
    on public.client_scope_client (client_id);

create index idx_cl_clscope
    on public.client_scope_client (scope_id);

create table public.default_client_scope
(
    realm_id      varchar(36)           not null
        constraint fk_r_def_cli_scope_realm
            references public.realm,
    scope_id      varchar(36)           not null,
    default_scope boolean default false not null,
    constraint r_def_cli_scope_bind
        primary key (realm_id, scope_id)
);

alter table public.default_client_scope
    owner to keycloak;

create index idx_defcls_realm
    on public.default_client_scope (realm_id);

create index idx_defcls_scope
    on public.default_client_scope (scope_id);

create table public.user_consent_client_scope
(
    user_consent_id varchar(36) not null
        constraint fk_grntcsnt_clsc_usc
            references public.user_consent,
    scope_id        varchar(36) not null,
    constraint constraint_grntcsnt_clsc_pm
        primary key (user_consent_id, scope_id)
);

alter table public.user_consent_client_scope
    owner to keycloak;

create index idx_usconsent_clscope
    on public.user_consent_client_scope (user_consent_id);

create index idx_usconsent_scope_id
    on public.user_consent_client_scope (scope_id);

create table public.fed_user_consent_cl_scope
(
    user_consent_id varchar(36) not null,
    scope_id        varchar(36) not null,
    constraint constraint_fgrntcsnt_clsc_pm
        primary key (user_consent_id, scope_id)
);

alter table public.fed_user_consent_cl_scope
    owner to keycloak;

create table public.resource_server_perm_ticket
(
    id                 varchar(36)  not null
        constraint constraint_fapmt
            primary key,
    owner              varchar(255) not null,
    requester          varchar(255) not null,
    created_timestamp  bigint       not null,
    granted_timestamp  bigint,
    resource_id        varchar(36)  not null
        constraint fk_frsrho213xcx4wnkog83sspmt
            references public.resource_server_resource,
    scope_id           varchar(36)
        constraint fk_frsrho213xcx4wnkog84sspmt
            references public.resource_server_scope,
    resource_server_id varchar(36)  not null
        constraint fk_frsrho213xcx4wnkog82sspmt
            references public.resource_server,
    policy_id          varchar(36)
        constraint fk_frsrpo2128cx4wnkog82ssrfy
            references public.resource_server_policy,
    constraint uk_frsr6t700s9v50bu18ws5pmt
        unique (owner, requester, resource_server_id, resource_id, scope_id)
);

alter table public.resource_server_perm_ticket
    owner to keycloak;

create index idx_perm_ticket_requester
    on public.resource_server_perm_ticket (requester);

create index idx_perm_ticket_owner
    on public.resource_server_perm_ticket (owner);

create table public.resource_attribute
(
    id          varchar(36) default 'sybase-needs-something-here'::character varying not null
        constraint res_attr_pk
            primary key,
    name        varchar(255)                                                         not null,
    value       varchar(255),
    resource_id varchar(36)                                                          not null
        constraint fk_5hrm2vlf9ql5fu022kqepovbr
            references public.resource_server_resource
);

alter table public.resource_attribute
    owner to keycloak;

create table public.resource_uris
(
    resource_id varchar(36)  not null
        constraint fk_resource_server_uris
            references public.resource_server_resource,
    value       varchar(255) not null,
    constraint constraint_resour_uris_pk
        primary key (resource_id, value)
);

alter table public.resource_uris
    owner to keycloak;

create table public.role_attribute
(
    id      varchar(36)  not null
        constraint constraint_role_attribute_pk
            primary key,
    role_id varchar(36)  not null
        constraint fk_role_attribute_id
            references public.keycloak_role,
    name    varchar(255) not null,
    value   varchar(255)
);

alter table public.role_attribute
    owner to keycloak;

create index idx_role_attribute
    on public.role_attribute (role_id);

create table public.realm_localizations
(
    realm_id varchar(255) not null,
    locale   varchar(255) not null,
    texts    text         not null,
    primary key (realm_id, locale)
);

alter table public.realm_localizations
    owner to keycloak;

create table public.org
(
    id           varchar(255) not null
        constraint "ORG_pkey"
            primary key,
    enabled      boolean      not null,
    realm_id     varchar(255) not null,
    group_id     varchar(255) not null
        constraint uk_org_group
            unique,
    name         varchar(255) not null,
    description  varchar(4000),
    alias        varchar(255) not null,
    redirect_url varchar(2048),
    constraint uk_org_name
        unique (realm_id, name),
    constraint uk_org_alias
        unique (realm_id, alias)
);

alter table public.org
    owner to keycloak;

create table public.org_domain
(
    id       varchar(36)  not null,
    name     varchar(255) not null,
    verified boolean      not null,
    org_id   varchar(255) not null,
    constraint "ORG_DOMAIN_pkey"
        primary key (id, name)
);

alter table public.org_domain
    owner to keycloak;

create index idx_org_domain_org_id
    on public.org_domain (org_id);

create table public.revoked_token
(
    id     varchar(255) not null
        constraint constraint_rt
            primary key,
    expire bigint       not null
);

alter table public.revoked_token
    owner to keycloak;

create index idx_rev_token_on_expire
    on public.revoked_token (expire);

create table public.users
(
    id         bigserial
        primary key,
    first_name varchar(100)                           not null,
    last_name  varchar(100)                           not null,
    email      varchar(255)                           not null
        unique,
    password   varchar(255)                           not null,
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone,
    is_active  boolean                  default true
);

comment on table public.users is 'A table for store users info. Author: Viktor Kyarginskiy';

comment on column public.users.id is 'Unique identifier for each user';

comment on column public.users.first_name is 'User''s first name';

comment on column public.users.last_name is 'User''s last name';

comment on column public.users.email is 'User''s email, must be unique';

comment on column public.users.password is 'Hashed password for user authentication';

comment on column public.users.created_at is 'Timestamp when the user was created';

comment on column public.users.updated_at is 'Timestamp when the user was last updated';

comment on column public.users.is_active is 'Indicates if the user is currently active';

alter table public.users
    owner to keycloak;

create unique index idx_users_email
    on public.users (email);

