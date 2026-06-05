#!/usr/bin/env sh
set -eu

bundle exec ruby db/migrate.rb
exec bundle exec rackup --host 0.0.0.0 --port "${PORT:-7863}"
