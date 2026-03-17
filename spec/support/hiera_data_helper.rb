# frozen_string_literal: true

require 'yaml'

# Resolves this module's Hiera data hierarchy for a given os facts hash
# (the value of facts[:os]).  Files are merged in lowest-to-highest priority
# order so higher-priority entries win, matching Hiera's "first found" semantics.
#
# The hierarchy mirrors hiera.yaml:
#   1. os/{name}-{major}.yaml        (highest priority)
#   2. os/{name}.yaml
#   3. os/{family}-{major}.yaml
#   4. os/{family}.yaml
#   5. common.yaml                   (lowest priority)
#
# Usage:
#   hiera = module_hiera_data(facts[:os])
#   hiera['sssd::config::sssd_config_dir_mode']
#   hiera.dig('sssd::config::sssd_config_file_params', 'group')
#
DATA_DIR = File.expand_path('../../data', __dir__)

def module_hiera_data(os)
  name   = os[:name]
  family = os[:family]
  major  = os[:release][:major]

  files = [
    File.join(DATA_DIR, 'os', "#{name}-#{major}.yaml"),
    File.join(DATA_DIR, 'os', "#{name}.yaml"),
    File.join(DATA_DIR, 'os', "#{family}-#{major}.yaml"),
    File.join(DATA_DIR, 'os', "#{family}.yaml"),
    File.join(DATA_DIR, 'common.yaml'),
  ]

  result = {}
  files.reverse_each do |f|
    next unless File.exist?(f)

    data = YAML.safe_load(File.read(f))
    result.merge!(data) if data.is_a?(Hash)
  end
  result
end
