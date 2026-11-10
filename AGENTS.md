# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`simp-sssd` is a SIMP Puppet module that installs and configures **SSSD** (the
System Security Services Daemon). SSSD is the client-side daemon that talks to
remote identity/authentication back-ends (LDAP, Active Directory, FreeIPA,
Kerberos, or local files) and exposes them to the OS through NSS/PAM. This
module manages three things:

1. **Domains** (`sssd::domain`) — the `[domain/<name>]` sections that describe
   *which* back-end a set of users comes from and how it is queried.
2. **Providers** (`sssd::provider::{ldap,ad,ipa,krb5,files}`) — the back-end
   wiring for a domain: the LDAP URIs, the AD servers, the Kerberos realm, etc.
3. **Responder services** (`sssd::service::{nss,pam,ssh,sudo,autofs,ifp,pac}`) —
   the `[<responder>]` sections that configure the individual SSSD front-ends.

The module edits `[sssd]` in `/etc/sssd/sssd.conf` and every other section
(domains, providers, responders) in an ordered snippet in `/etc/sssd/conf.d/`,
**one setting at a time** with `ini_setting` (`puppetlabs/inifile`). Since
11.0.0 a bare `include sssd` installs the packages and declares nothing else:
every setting, the service, the directories, the responders, the IPA and
`LOCAL` domains and the stale-snippet tidy are opt-in through parameters. The
shipped `simp:defaults` compliance_engine profile
(`SIMP/compliance_profiles/`) sets them back to their 10.x values.

### Business logic

The config-file model is the heart of this module. Every section is emitted
the same way: a manifest builds a Hash of setting name → value and hands it,
with the section name, to the **`sssd::config::entry`** define, which edits
each setting in place in `conf.d/<order>_<name>.conf` (or `sssd.conf`) and
notifies `Class['sssd::service']`. A value of `undef` leaves the setting
alone, `'absent'` removes it, anything else writes it.

- **`sssd` (`manifests/init.pp`)** — Public entry class (consumers
  `include 'sssd'`; not `assert_private()`'d). Key parameters:
  - `$domains_entries` (`Hash[String, Sssd::EntryOptions]`, default `{}`,
    deep-merged) — the domain names to list in the `[sssd]` `domains =` line,
    each edited as its own `ini_subsetting`. Listing a domain does **not**
    create it; you still declare `sssd::domain` / `sssd::provider::*`
    resources. `$domains` is the deprecated Array form (default `undef`);
    while it is set, even to `[]`, it is used *instead of* the Hash
    (`functions/entries.pp`).
  - `$services_entries` (`Hash[Sssd::Service, Sssd::EntryOptions]`, default
    `{}`, deep-merged) — the responder services; `$services` is its
    deprecated Array form, with the same precedence.
  - `$ldap_providers` (`Hash`, default `{}`, `init.pp`) — Hiera-driven
    convenience: each entry is splatted into an `sssd::provider::ldap` resource
    (`init.pp`).
  - `$auto_add_ipa_domain` (`Boolean`, default `false`, `init.pp`) — when the
    host is IPA-joined, auto-configure the IPA domain (see IPA path below).
  - `$auditd` / `$pki` / `$app_pki_cert_source` (`init.pp`) — SIMP
    integration toggles fed by the `simp_options::*` seam (table below).
  - `$custom_config` (`Optional[String]`, `init.pp`) — raw config written
    verbatim, as the whole of `conf.d/99999_puppet_custom_raw.conf`, **without
    validation** (`init.pp`).
  - `$custom_settings` (`Optional[Sssd::IniSettings]`, `init.pp`) — a Hash of
    section name → setting name → value, validated at compile time and edited
    in place in `conf.d/99999_puppet_custom.conf` (one `sssd::config::entry`
    per section). Unlike `custom_options` it *adds* sections rather than
    replacing module-managed ones. Prefer it over `$custom_config`.
  - `$tidy_puppet_snippets` (`Boolean`, default `false`) — destructive opt-in
    that `tidy`s unmanaged `*_puppet_*.conf` snippets.

  Control flow:
  - `include 'sssd::install'`, `'sssd::config'` and `'sssd::service'`, ordered
    `Class['sssd::install'] -> Class['sssd::config']` (`init.pp`).
  - **Version guard** (`init.pp`): `unless sssd::supported_version() {
    fail(...) }` — refuses to proceed on SSSD older than the supported baseline.
  - **PKI branch** (`init.pp`): when `$pki` is truthy, asserts the
    optional `simp/pki` dependency, `include`s `sssd::pki`, and orders
    `Class['sssd::config'] -> Class['sssd::pki']`.
  - **auditd branch** (`init.pp`): when `$auditd`, asserts the optional
    `simp/auditd` dependency, `include`s `auditd`, and adds an `auditd::rule`
    watching `/etc/sssd/`.
  - **`ldap_providers` loop** (`init.pp`): each hash entry becomes an
    `sssd::provider::ldap { $key: * => $value }`.

- **`sssd::install` (`manifests/install.pp`, `assert_private` at :20)** —
  installs `sssd` + `sssd-dbus` (`install.pp`), optionally `sssd-tools`
  when `$install_user_tools` (`install.pp`), and `include`s
  `sssd::install::client` when `$install_client` (`install.pp`), which
  installs `sssd-client` (`install/client.pp`). All use
  `$package_ensure` (from `simp_options::package_ensure`, `install.pp`).

- **`sssd::config` (`manifests/config.pp`, `assert_private` at :33)** —
  the `[sssd]` section builder.
  - **IPA auto-detection** (`config.pp`): if `$sssd::auto_add_ipa_domain`
    and the `ipa` fact is present, `include 'sssd::config::ipa_domain'` and merge
    `$facts['ipa']['domain']` into the computed domain list.
  - **Responders** (`config.pp`): when `$sssd::include_svc_config`, all seven
    `sssd::service::*` classes are included, listed or not, so a responder
    setting enforced alone takes effect. Listing only decides what runs.
  - Manages `/etc/sssd` and `/etc/sssd/conf.d` only when
    `$sssd_config_dir_mode` is set (or `$authoritative`, which purges
    `conf.d`). `tidy` of stale `*_puppet_*.conf` only with
    `$sssd::tidy_puppet_snippets` (`config.pp`).
  - Declares an `sssd::config::entry` for `[sssd]` in `/etc/sssd/sssd.conf`,
    and an `ini_subsetting` per `services`/`domains` entry, each new entry
    inserted after the one declared before it. While
    `sssd::service::sudo::socket_enable` is `true` and `sssd::sudo_on()`
    allows it, or `sudo` is in the deprecated `sssd::services`, `sudo` is
    edited as `absent`, because the socket refuses to start while `sudo` is
    listed; otherwise a `sudo` entry is edited like any other (`config.pp`).
    Read other classes' *parameters* (set at declaration), never variables
    from their bodies, so the result doesn't depend on evaluation order. `sssd.conf` is only declared as a `file` when an entry
    will be written into it: SSSD can't parse an empty one.
  - **`manage_base_domain`** (`config.pp`, default `false`): EL10+ requires at
    least one domain for SSSD to start, so a `LOCAL` proxy-to-`files` domain is
    declared when this is true. It is not listed automatically: the
    `simp:defaults` profile sets this and `domains_entries: {LOCAL: {}}` on
    EL10.

- **`sssd::config::entry` (`manifests/config/entry.pp`, `assert_private`
  at :17)** — the central section editor used by *every* domain, provider, and
  responder. Takes `$section` and a `$settings` Hash and declares one
  `ini_setting` per non-`undef` setting in `/etc/sssd/conf.d/<order>_<title>.conf`
  (via `simplib::safe_filename`, default `$order` = 50) or `$path`. The file
  itself is declared (contentless) only to apply
  `$sssd::config::sssd_config_file_params` — SSSD rejects files with looser
  permissions. Everything requires `Package['sssd']` and notifies
  `Class['sssd::service']`. Rejects a fully-qualified `$name` unless `$path`
  is set (`entry.pp`).

- **`sssd::config::ipa_domain` (`manifests/config/ipa_domain.pp`,
  `assert_private` at :4)** — when `$facts.dig('ipa','connected')`, declares an
  `sssd::domain` (all providers set to `ipa`) plus an `sssd::provider::ipa`
  keyed to the detected IPA domain/server (`ipa_domain.pp`).

- **`sssd::service` (`manifests/service.pp`, `assert_private` at :15)** —
  the actual `service { 'sssd' }` resource, declared only when `$ensure` or
  `$enable` (both default `undef`) is set (`service.pp`). The class is always
  included, so `notify => Class['sssd::service']` is safe either way.

- **`sssd::service::{nss,pam,ssh,sudo,autofs,ifp,pac}`** — the **responder**
  config sections. Each is a class whose parameters map to `sssd.conf(5)`
  options, all `undef` by default; it builds a settings Hash and emits an
  `sssd::config::entry`. If a `$custom_options` hash is supplied instead, only
  those settings are managed and the typed parameters are skipped (see
  `service/nss.pp` for the canonical shape). `sudo` additionally manages a
  systemd drop-in (`manage_group_dropin_file`) and `sssd-sudo.socket`
  (`socket_enable`), each only when set; `true` is ignored while sudo is
  turned off in the services list (`absent`, or a legacy Array without it).
  `sudo` in the legacy Array enables the socket while `socket_enable` is
  unset, as 10.x did, so a newly built node still gets a responder.

- **`sssd::pki` (`manifests/pki.pp`, `assert_private` at :26)** — when
  `$sssd::pki` is truthy, `pki::copy { 'sssd' }` copies certs from
  `$app_pki_cert_source` into `/etc/pki/simp_apps/sssd/x509`, notifying the
  service (`pki.pp`). `$pki` accepts `'simp'` (include SIMP's `pki`
  module), `true` (copy but don't include `pki`), or `false` (do nothing;
  manage the `app_pki_*` paths yourself).

- **`sssd::domain` (`manifests/domain.pp`)** — a define that writes one
  `[domain/<name>]` section. `$id_provider` (`Sssd::IdProvider`) is the only
  **required** parameter (`domain.pp`); the other provider *selectors*
  (`auth_provider`, `access_provider`, `chpass_provider`, `sudo_provider`,
  `selinux_provider`, `subdomains_provider`, `autofs_provider`, `hostid_provider`,
  `domain.pp`) are optional strings that name the back-end *type* to use
  for that facet. It emits an `sssd::config::entry` named
  `puppet_domain_${name}` (`domain.pp`). A domain by itself only names
  providers; the provider *settings* come from the `sssd::provider::*` defines.

- **`sssd::provider::{ldap,ad,ipa,krb5,files}` (`manifests/provider/*.pp`)** —
  defines that add the back-end-specific keys to a domain. **The `$name` of the
  provider must match the `sssd::domain` `$name`** — that is how a provider's
  settings attach to a domain. Each emits an `sssd::config::entry` named
  `puppet_provider_${name}_<type>`:
  - **`ldap`** — LDAP URIs, bind DN/pw, schema, TLS. Its bind/URI parameters are
    the module's LDAP `simp_options` seam (`provider/ldap.pp`).
  - **`ad`** — Active Directory: `ad_domain`/`ad_servers`, GPO access-control
    mapping, dynamic DNS; `ldap_id_mapping`/`ldap_use_tokengroups` default true.
  - **`ipa`** — FreeIPA: `ipa_domain`/`ipa_server`, HBAC/SELinux/automount search
    bases, `_srv_` DNS-SRV discovery, `ldap_tls_cacert` default `/etc/ipa/ca.crt`.
  - **`krb5`** — Kerberos: `krb5_realm` (required), servers, ccache, FAST.
  - **`files`** — the local `files` provider (`passwd`/`group` file lists).

### Gotchas / non-obvious details

- **Declaring a domain is three steps, not one.** Add the name to `sssd::domains_entries`
  (so it lands in the `[sssd]` `domains =` line), declare `sssd::domain { NAME }`
  with an `id_provider`, and declare the matching
  `sssd::provider::<type> { NAME }` for the actual back-end settings. The name
  is the join key across all three (`domain.pp`; `init.pp`).
- **Everything routes through `sssd::config::entry`.** Domains, providers, and
  responders all become settings in `conf.d/<order>_<name>.conf` snippets.
  Only the `[sssd]` section itself lives in `sssd.conf` (`config.pp`). This is
  the seam a new section should hook into. Never render a section as a whole
  file: an unset parameter must leave its setting alone.
- **The defines keep literal defaults.** `sssd::domain` and `sssd::provider::*`
  write their defaults whenever declared (declaring one is the opt-in), and
  the profile can't reach define parameters, so changing those defaults is a
  silent behavior change for every consumer.
- **`sudo` is removed from the `services =` line while the socket is
  enabled** (`config.pp`): `sssd-sudo.socket`'s `ExecStartPre` fails while
  `sudo` is listed. Don't "fix" the missing `sudo` in the services line.
- **Never create a file without writing into it.** `sssd::config::entry`
  declares its `file` only when a setting is written, not for `'absent'`
  ones: SSSD can't parse an empty `sssd.conf`, and an empty snippet fails
  `sssctl config-check`.
- **Responder classes are always `include`d**, so a resource-like
  `class { 'sssd::service::<name>': }` must be evaluated before
  `include sssd`; prefer Hiera.
- **`$custom_config` and per-section `custom_options` bypass validation.** They
  are written verbatim (`init.pp`; `service/nss.pp`). Typos land in `sssd.conf` unchecked and can stop the
  daemon. `$custom_settings` is the validated alternative — its structure is
  type-checked at compile time (`types/inisettings.pp`), though setting *names*
  are only pattern-checked, not validated against sssd's schema.
- **`authoritative` and `tidy_puppet_snippets` are foot-guns, off by
  default.** `authoritative` purges *all* unmanaged files in `/etc/sssd/conf.d`;
  `tidy_puppet_snippets` removes Puppet's own unmanaged `*_puppet_*.conf`
  (`config.pp`). The `simp:defaults` profile turns the tidy on.
- **EL10 needs a domain to even start.** `manage_base_domain` (`config.pp`)
  declares a `LOCAL` proxy/`files` domain so SSSD can start on a host with no
  real domain configured; it still has to be listed in `domains_entries`.
  The profile does both on EL10 only.
- **IPA auto-config is opt-in.** With `auto_add_ipa_domain => true` (set by the
  profile), on an IPA-joined host a domain + `ipa` provider are created
  automatically (`config.pp`; `config/ipa_domain.pp`).
- **The version guard depends on the `sssd_version` fact.** `sssd_version`
  shells out to `sssd --version` and is only present when the `sssd` binary is
  on `PATH` (`lib/facter/sssd_version.rb`); `sssd::supported_version()`
  returns `true` when the fact is absent (assumes a modern system) and `false`
  only when it is present and `< 1.16.0` (`functions/supported_version.pp`).
  The guard does not decide whether the service is managed (`service.pp`).
- **`simp/pki` and `simp/auditd` are optional dependencies**, asserted at
  runtime with `simplib::assert_optional_dependency` only when the corresponding
  toggle is on (`init.pp`) — they are *not* hard `metadata.json`
  dependencies.

## The `simp_options` / `simplib::lookup` seam

This is the module's real business-logic seam (the natural target for a
lookup-path unit test). All calls resolve `simp_options::*` with an explicit
`default_value`, so the module works whether or not `simp_options` is included:

| Key | Location | `default_value` |
|-----|----------|-----------------|
| `simp_options::auditd` | `init.pp` | `false` |
| `simp_options::pki` | `init.pp` | `false` |
| `simp_options::pki::source` | `init.pp` | `'/etc/pki/simp/x509'` |
| `simp_options::package_ensure` | `install.pp` | `'installed'` |
| `simp_options::ldap::uri` | `provider/ldap.pp` | `undef` |
| `simp_options::ldap::base_dn` | `provider/ldap.pp` | `undef` |
| `simp_options::ldap::bind_dn` | `provider/ldap.pp` | `undef` |
| `simp_options::ldap::bind_pw` | `provider/ldap.pp` | `undef` |

Keep routing SIMP feature toggles through `simplib::lookup('simp_options::*', {
'default_value' => ... })` with an explicit default rather than assuming
`simp_options` is included.

## Dependencies

Hard dependencies (from `metadata.json`):

- `puppet/systemd` `>= 4.0.2 < 10.0.0` (systemd drop-ins / socket units, e.g.
  the `sssd-sudo.socket` managed by the `sudo` responder)
- `puppetlabs/stdlib` `>= 8.0.0 < 10.0.0`
- `simp/simplib` `>= 4.9.0 < 6.0.0` (provides `simplib::lookup`,
  `simplib::assert_optional_dependency`, `simplib::safe_filename`, and the
  `Simplib::URI` / `Stdlib::Absolutepath` types)

Optional dependencies (from `metadata.json` `simp.optional_dependencies`, each
asserted at runtime via `assert_optional_dependency`):

- `simp/pki` `>= 6.2.0 < 7.0.0` — asserted at `manifests/init.pp` when
  `$pki` is truthy.
- `simp/auditd` `>= 8.5.0 < 10.0.0` — asserted at `manifests/init.pp` when
  `$auditd` is true.

Runtime requirement (from `metadata.json` `requirements`): `openvox
>= 8.0.0 < 9.0.0`.

Supported OS matrix (from `metadata.json`): CentOS 9/10; RedHat 8/9/10;
OracleLinux 8/9/10; Rocky 8/9/10; AlmaLinux 8/9/10.

## Repository layout

- `manifests/init.pp` — the `sssd` public class (orchestration + `[sssd]` params).
- `manifests/install.pp`, `manifests/install/client.pp` — package install.
- `manifests/config.pp` — writes `[sssd]` into `sssd.conf`, loops responders.
- `manifests/config/entry.pp` — the `sssd::config::entry` define; the central
  `conf.d/` snippet writer that every section flows through.
- `manifests/config/ipa_domain.pp` — IPA auto-domain when the host is IPA-joined.
- `manifests/service.pp` — the `service { 'sssd' }` resource.
- `manifests/service/{nss,pam,ssh,sudo,autofs,ifp,pac}.pp` — the seven responder
  config classes.
- `manifests/pki.pp` — `pki::copy` cert management.
- `manifests/domain.pp` — the `sssd::domain` define (`[domain/<name>]`).
- `manifests/provider/{ldap,ad,ipa,krb5,files}.pp` — the five provider defines.
- `functions/supported_version.pp` — `sssd::supported_version()` (Puppet-lang
  function).
- `functions/to_ini.pp` — `sssd::to_ini()` (Puppet-lang function): renders an
  `Sssd::IniSettings` Hash as INI text (insertion-ordered, `undef` settings
  omitted, Arrays comma-joined).
- `lib/facter/sssd_version.rb` — the `sssd_version` fact (`sssd --version`).
- `types/` — 21 data types constraining config values (`Sssd::Services`,
  `Sssd::Service`, `Sssd::EntryOptions`, `Sssd::IniListItem`,
  `Sssd::SimpleAccessList`,
  `Sssd::IdProvider`, `Sssd::AuthProvider`, `Sssd::AccessProvider`,
  `Sssd::ChpassProvider`, `Sssd::DebugLevel`, `Sssd::LdapSchema`,
  `Sssd::LdapAccessOrder`, `Sssd::LdapAccountExpirePol`, `Sssd::LdapDefaultAuthtok`,
  `Sssd::LdapDeref`, `Sssd::LdapTlsReqcert`, `Sssd::ADDefaultRight`,
  `Sssd::Krb5Server`, `Sssd::IniSettings`, `Sssd::IniSectionName`,
  `Sssd::IniValue`).
- `functions/entries.pp` — `sssd::entries()`: resolves a `*_entries` Hash (or
  its deprecated Array) to entry → `present`/`absent`.
- `functions/sudo_on.pp` — `sssd::sudo_on()`: whether the services list
  leaves the sudo responder on; shared by `config.pp` and `service/sudo.pp`.
- `SIMP/compliance_profiles/` — the `simp:defaults` profile and its checks;
  per-release values use `confine:`. `spec/classes/simp_defaults_profile_spec.rb`
  asserts it reproduces the 10.x catalog.
- `data/`, `hiera.yaml` — module data, limited to what the module needs to
  work on each release (`sssd_config_file_params`, `app_pki_group`) and the
  `deep` merge of the `*_entries` Hashes. 10.x defaults belong in the profile.
- `spec/classes/`, `spec/defines/` — rspec-puppet unit tests.
- `spec/acceptance/` — beaker suites; nodesets under
  `spec/acceptance/nodesets/`.
- `REFERENCE.md` — generated Puppet Strings reference.
- **Acceptance runs in CI:** `.github/workflows/pr_tests.yml` has an
  `acceptance` job (`pr_tests.yml`) on nodes `almalinux9`/`almalinux10`
  under `BEAKER_HYPERVISOR: 'vagrant_libvirt'` (`pr_tests.yml`), alongside
  the standard syntax/unit jobs.

## Common commands

```sh
# Install dependencies
bundle install

# Run all unit tests
bundle exec rake spec

# Run a single spec
bundle exec rspec spec/defines/domain_spec.rb

# Puppet lint
bundle exec rake lint

# Ruby lint
bundle exec rake rubocop

# Regenerate REFERENCE.md from puppet-strings docstrings
puppet strings generate --format markdown --out REFERENCE.md

# Run the default beaker acceptance suite
bundle exec rake beaker:suites[default]
```

Relevant gem pins (from `Gemfile`): `puppetlabs_spec_helper ~> 8.0.0`,
`simp-rake-helpers ~> 5.24.0`, `simp-beaker-helpers ~> 2.0.0`. Rubocop is pinned
to `~> 1.88.0`. The `Gemfile` installs **both** the `openvox` and `puppet` gems
(`Gemfile`) and defaults the tested version range to `>= 8 < 9`
(`Gemfile`). `spec/spec_helper.rb` requires
`puppetlabs_spec_helper/module_spec_helper`. There are 15 nodesets
(almalinux8/9/10, centos9/10, default, oel8/9/10, rhel8/9/10, rocky8/9/10).

## Conventions

- **Emit new config sections through `sssd::config::entry`**, building a
  settings Hash the way the existing domain/provider/responder manifests do.
  Do not write to `sssd.conf` directly — only the `[sssd]` section lives
  there.
- **New class parameters default to `undef`** (leave the setting alone) and
  accept `'absent'`; when one restores 10.x behavior, add a check to
  `SIMP/compliance_profiles/` and the profile spec.
- **Keep the domain ↔ provider `$name` contract.** A `sssd::provider::*`
  attaches to a `sssd::domain` solely by sharing its `$name`.
- **Guard optional integrations** (`simp/pki`, `simp/auditd`) with
  `simplib::assert_optional_dependency` and a toggle check, as `init.pp`
  does — don't hard-`include` optional modules.
- Continue routing SIMP feature toggles through
  `simplib::lookup('simp_options::*', { 'default_value' => ... })` rather than
  assuming `simp_options` is included.
- **Preserve `assert_private()`** in the private classes/defines (`install.pp`,
  `config.pp`, `config/entry.pp`, `config/ipa_domain.pp`, `service.pp`,
  `pki.pp`) — only `sssd`, `sssd::domain`, and the `sssd::provider::*` /
  `sssd::service::*` sections are consumer-facing.
- Preserve the `@summary` / `@param` puppet-strings docstrings — they drive
  `REFERENCE.md`; regenerate it after changing docs or parameters.
- `Gemfile`, `spec/spec_helper.rb`, and `.github/workflows/pr_tests.yml` are
  **puppetsync**-managed baseline files; the next sync overwrites local edits.
  Push changes to those upstream to the baseline, not here.
- Match the existing 2-space Puppet indentation and aligned-arrow parameter
  style.
