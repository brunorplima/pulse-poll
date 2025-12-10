#!/usr/bin/env bash
# Build script for Render deployment
# exit on error
set -o errexit

bundle install
bundle exec rails db:migrate

