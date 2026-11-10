# Helpers shared by the default acceptance suite. Include the module in a
# describe block.
module SssdTestUtil
  # Hieradata that enforces the module's `simp:defaults` profile, once the
  # Compliance Engine layer is in the hierarchy (see #with_compliance_engine).
  SIMP_DEFAULTS = { 'compliance_engine::enforcement' => ['simp:defaults'] }.freeze

  # Adds the Compliance Engine layer to the environment's hiera.yaml, last, so
  # it has the lowest priority, as it does at a real site. Without
  # `compliance_engine::enforcement` in the hieradata the layer supplies
  # nothing, so it can stay in place for the whole suite.
  #
  # @param host [Beaker::Host]
  def with_compliance_engine(host)
    config = YAML.safe_load(get_hiera_config_on(host))
    return if config['hierarchy'].any? { |level| level['lookup_key'] == 'compliance_engine::enforcement' }

    config['hierarchy'] << {
      'name'       => 'Compliance Engine',
      'lookup_key' => 'compliance_engine::enforcement',
    }
    set_hiera_config_on(host, config)
  end

  # The checksum, owner, group and mode of every file under /etc/sssd
  #
  # @param host [Beaker::Host]
  # @return [String]
  def etc_sssd_state(host)
    on(host, 'find /etc/sssd -type f -exec stat -c "%n %U:%G %a" {} \; -exec sha256sum {} \; | sort').stdout
  end
end
