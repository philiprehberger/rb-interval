# frozen_string_literal: true

require_relative 'lib/philiprehberger/interval/version'

Gem::Specification.new do |spec|
  spec.name          = 'philiprehberger-interval'
  spec.version       = Philiprehberger::Interval::VERSION
  spec.authors       = ['Philip Rehberger']
  spec.email         = ['me@philiprehberger.com']

  spec.summary       = 'Interval data type with overlap detection, merging, and gap finding'
  spec.description   = 'Closed interval data type supporting overlap detection, containment, ' \
                       'intersection, union, subtraction, merging collections, and finding gaps. ' \
                       'Works with any Comparable type including Numeric and Time.'
  spec.homepage      = 'https://github.com/philiprehberger/rb-interval'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = spec.homepage
  spec.metadata['changelog_uri']         = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']       = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
