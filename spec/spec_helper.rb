require 'rubygems'
require 'bundler/setup'

require File.expand_path('../../lib/linkr_checkr', __FILE__)

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = 'random'
end

