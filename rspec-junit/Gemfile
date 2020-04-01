# frozen_string_literal: true

# source 'https://repo.getperx.org/repository/gems'
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Pinned transitive dependencies
# we get this from dry-transaction and it should be removed when dry-transaction is updated
gem 'dry-monads', '< 1.0' # massive breaking changes in 1.0: https://github.com/dry-rb/dry-monads/blob/docsite-1.0/CHANGELOG.md#breaking-changes

# Normal dependencies
gem 'aasm'
gem 'active_model_otp'
gem 'active_model_serializers'
gem 'active_record_extended'
gem 'activerecord-import'
gem 'activerecord-postgis-adapter'
gem 'activerecord-sort'
gem 'acts_as_list'
gem 'addressable' # for Scheduled Reports
gem 'aws-sdk-firehose'
gem 'aws-sdk-s3'
gem 'aws-sdk-sns'
gem 'aws-sdk-sqs'
gem 'aws-sigv4'
gem 'barby'
gem 'blueprinter'
gem 'bootsnap', require: false
gem 'carrierwave', '1.2.2' # 1.2.3 breaks localstack and we need to replace this with active_storage for rails 6 anyway
gem 'concurrent-ruby', require: 'concurrent'
gem 'config'
gem 'counter_culture'
gem 'devise'
gem 'devise-security'
gem 'devise_invitable'
gem 'doorkeeper'
gem 'dry-transaction', '< 0.11.0' # massive breaking changes in 0.11.0: https://github.com/dry-rb/dry-transaction/blob/v0.11.0/CHANGELOG.md#changed
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'factory_bot_rails', '< 5.0', require: false # breaking changes in 5.0
gem 'faker' # required for seeding branch environments
gem 'fog-aws'
gem 'globalize'
gem 'globalize-accessors'
gem 'globalize-versioning'
gem 'hash_dot'
gem 'health-monitor-rails'
gem 'http_accept_language'
gem 'invalid_utf8_rejector'
gem 'iso8601'
gem 'json_schemer'
gem 'jsonapi-resources'
gem 'jwt'
gem 'kaminari'
gem 'karafka'
gem 'liquid'
gem 'lograge'
gem 'logstash-event'
gem 'mini_magick'
gem 'nokogiri'
gem 'oj'
gem 'overcommit'
gem 'paper_trail'
gem 'paper_trail-association_tracking'
gem 'paranoia'
gem 'pg'
gem 'prometheus_exporter'
gem 'pry-rails'
gem 'puma'
gem 'pundit'
gem 'rack-cors'
gem 'rack-fluentd-logger'
gem 'rails', '~> 6.0.2'
gem 'rake', '~> 12.3' # Hard dependency by sneakers
gem 'redis'
gem 'redis-mutex'
gem 'request_store'
gem 'retryable'
gem 'rgeo'
gem 'rgeo-activerecord'
gem 'ros-apartment', require: 'apartment'
gem 'rqrcode' # needed by barby which doesn't specify it as a dependency
gem 'rspec-html-matchers'
gem 'ruby-limiter'
gem 'rubyXL'
gem 'scenic'
gem 'sentry-raven'
gem 'sneakers'
gem 'strong_migrations'
gem 'unicode-display_width'
# Perx ML API gem
gem 'perxtech-ml', git: 'https://github.com/PerxTech/perx-ml-api-client.git', glob: 'sdk/ruby/*.gemspec'

group :production do
  gem 'google-cloud-trace'
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'brakeman', require: false
  gem 'bunny-mock'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'database_cleaner'
  gem 'db-query-matchers'
  gem 'fuubar' # Better formatter for rspec
  gem 'rspec-benchmark'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'spring-commands-rspec'
  gem 'test-prof'
  gem 'timecop'
end

group :development do
  gem 'bullet'
  gem 'debase'
  gem 'listen'
  gem 'ruby-debug-ide'
  gem 'solargraph' # For editors with LSP support
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'yard'
  gem 'yard-rails'
  gem 'yard-rspec'
end

group :test do
  # gem 'danger'
  # gem 'danger-junit'
  gem 'karafka-testing'
  # provide JUnit formatters so that we can collect during CI
  gem 'rspec_junit_formatter'
  gem 'webmock', '~> 3.7', '>= 3.7.6'
end

group :profile do
  gem 'memory_profiler' # required by spec/support/gem_tracker.rb
  gem 'ruby-prof'
  gem 'ruby-prof-flamegraph'
end
