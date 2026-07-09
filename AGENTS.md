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

The module writes `[sssd]` into `/etc/sssd/sssd.conf` and writes every other
section (domains, providers, responders) as an ordered snippet in
`/etc/sssd/conf.d/`. Applying the base `sssd` class with no domains configured
gives you a running daemon that does very little — domains and providers are
supplied by the operator (directly, or via the `ldap_providers` hash / IPA
auto-detection).

**It forcefully disables `nscd`** — you cannot run an `nscd` module at the same
time; this is intentional (`manifests/init.pp`).

### Business logic

The config-file model is the heart of this module. Almost every section is
emitted the same way: a manifest builds an array of `key = value` lines, joins
them, wraps the result in an INI section header via `templates/generic.epp`, and
hands it to the **`sssd::config::entry`** define, which writes it to a
`conf.d/<order>_<name>.conf` file and notifies the daemon.

- **`sssd` (`manifests/init.pp`)** — Public entry class (consumers
  `include 'sssd'`; not `assert_private()`'d). Key parameters:
  - `$domains` (`Array[String]`, default `[]`, `init.pp`) — the domain names
    to list in the `[sssd]` `domains =` line. Listing a domain here does **not**
    create it; you still declare `sssd::domain` / `sssd::provider::*` resources.
  - `$services` (`Sssd::Services`, default `['nss','pam','ssh','sudo']`,
    `init.pp`) — the responder services.
  - `$ldap_providers` (`Hash`, default `{}`, `init.pp`) — Hiera-driven
    convenience: each entry is splatted into an `sssd::provider::ldap` resource
    (`init.pp`).
  - `$auto_add_ipa_domain` (`Boolean`, default `true`, `init.pp`) — when the
    host is IPA-joined, auto-configure the IPA domain (see IPA path below).
  - `$auditd` / `$pki` / `$app_pki_cert_source` (`init.pp`) — SIMP
    integration toggles fed by the `simp_options::*` seam (table below).
  - `$custom_config` (`Optional[String]`, `init.pp`) — raw config appended
    verbatim to `conf.d/99999_puppet_custom.conf` **without validation**
    (`init.pp`).

  Control flow:
  - `include 'sssd::install'` then `include 'sssd::config'`, ordered
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
  - **Responder loop** (`config.pp`): when `$sssd::include_svc_config`,
    `include "sssd::service::${service}"` for each service in `$services`.
  - Manages `/etc/sssd` and `/etc/sssd/conf.d` directories; `purge` on `conf.d`
    is driven by `$authoritative` (`config.pp`). When **not**
    authoritative it instead `tidy`s stale `*_puppet_*.conf` files
    (`config.pp`).
  - Builds the `[sssd]` line array and writes `/etc/sssd/sssd.conf` via
    `generic.epp`, `notify => Class['sssd::service']` (`config.pp`). Note
    `sudo` is filtered out of the `services =` line because it is socket-activated
    (`config.pp`).
  - **`manage_base_domain`** (`config.pp`): EL10+ requires at least one
    domain for SSSD to start, so a `LOCAL` proxy-to-`files` domain is declared
    when this is true. This is set in module Hiera per OS.

- **`sssd::config::entry` (`manifests/config/entry.pp`, `assert_private`
  at :17)** — the central snippet writer used by *every* domain, provider, and
  responder. Writes `/etc/sssd/conf.d/<order>_<title>.conf` (via
  `simplib::safe_filename`, default `$order` = 50), applies
  `$sssd::config::sssd_config_file_params`, and `notify => Class['sssd::service']`.
  Rejects a fully-qualified `$name` (`entry.pp`).

- **`sssd::config::ipa_domain` (`manifests/config/ipa_domain.pp`,
  `assert_private` at :4)** — when `$facts.dig('ipa','connected')`, declares an
  `sssd::domain` (all providers set to `ipa`) plus an `sssd::provider::ipa`
  keyed to the detected IPA domain/server (`ipa_domain.pp`).

- **`sssd::service` (`manifests/service.pp`, `assert_private` at :15)** —
  the actual `service { 'sssd' }` resource. `$ensure`/`$enable` both default to
  `sssd::supported_version()` (`service.pp`), i.e. the daemon is only
  running/enabled on a supported SSSD.

- **`sssd::service::{nss,pam,ssh,sudo,autofs,ifp,pac}`** — the **responder**
  config sections. Each is a class whose parameters map to `sssd.conf(5)`
  options; it builds a line array, renders it through `generic.epp` (title =
  responder name), and emits an `sssd::config::entry`. If a `$custom_options`
  hash is supplied instead, it renders `templates/service/custom_options.epp`
  and skips the typed parameters entirely (see `service/nss.pp` for the
  canonical shape). `sudo` additionally manages a systemd drop-in / the
  `sssd-sudo.socket` (socket activation).

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

- **Declaring a domain is three steps, not one.** Add the name to `sssd::domains`
  (so it lands in the `[sssd]` `domains =` line), declare `sssd::domain { NAME }`
  with an `id_provider`, and declare the matching
  `sssd::provider::<type> { NAME }` for the actual back-end settings. The name
  is the join key across all three (`domain.pp`; `init.pp`).
- **Everything routes through `sssd::config::entry`.** Domains, providers, and
  responders all become `conf.d/<order>_<name>.conf` snippets, never direct edits
  to `sssd.conf`. Only the `[sssd]` section itself lives in `sssd.conf`
  (`config.pp`). This is the seam a new section should hook into.
- **`sudo` is socket-activated and is stripped from the `services =` line**
  (`config.pp`); the `sssd::service::sudo` responder manages the
  `sssd-sudo.socket` instead. Don't "fix" the missing `sudo` in the services
  line.
- **`$custom_config` and per-section `custom_options` bypass validation.** They
  are written verbatim (`init.pp`; `service/nss.pp` via
  `custom_options.epp`). Typos land in `sssd.conf` unchecked and can stop the
  daemon.
- **`authoritative` is a foot-gun.** `true` purges *all* unmanaged files in
  `/etc/sssd/conf.d` (`config.pp`); `false` only tidies Puppet's own
  `*_puppet_*.conf` (`config.pp`).
- **EL10 needs a domain to even start.** `manage_base_domain` (module Hiera,
  `config.pp`) declares a `LOCAL` proxy/`files` domain so SSSD can start
  on a host with no real domain configured.
- **IPA auto-config is on by default.** On an IPA-joined host, a domain +
  `ipa` provider are created automatically (`config.pp`;
  `config/ipa_domain.pp`). Set `auto_add_ipa_domain => false` to manage it
  yourself.
- **The version guard depends on the `sssd_version` fact.** `sssd_version`
  shells out to `sssd --version` and is only present when the `sssd` binary is
  on `PATH` (`lib/facter/sssd_version.rb`); `sssd::supported_version()`
  returns `true` when the fact is absent (assumes a modern system) and `false`
  only when it is present and `< 1.16.0` (`functions/supported_version.pp`).
  When the fact is missing, the daemon defaults to running/enabled
  (`service.pp`).
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
- `lib/facter/sssd_version.rb` — the `sssd_version` fact (`sssd --version`).
- `types/` — 13 data types constraining config values (`Sssd::Services`,
  `Sssd::IdProvider`, `Sssd::AuthProvider`, `Sssd::AccessProvider`,
  `Sssd::ChpassProvider`, `Sssd::DebugLevel`, `Sssd::LdapSchema`,
  `Sssd::LdapAccessOrder`, `Sssd::LdapAccountExpirePol`, `Sssd::LdapDefaultAuthtok`,
  `Sssd::LdapDeref`, `Sssd::LdapTlsReqcert`, `Sssd::ADDefaultRight`).
- `templates/generic.epp` — INI section renderer: `[title]` + content.
- `templates/service/custom_options.epp` — renders a `[service]` section from a
  raw `key => value` hash (used by the `custom_options` escape hatch).
- `data/`, `hiera.yaml` — module data (e.g. `manage_base_domain`,
  `sssd_config_file_params` per OS).
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

- **Emit new config sections through `sssd::config::entry`**, building a line
  array + `generic.epp` the way the existing domain/provider/responder manifests
  do. Do not write to `sssd.conf` directly — only the `[sssd]` section lives
  there.
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
