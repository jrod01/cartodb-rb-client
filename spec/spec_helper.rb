require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
  $LOAD_PATH.unshift(File.dirname(__FILE__))
  require 'rspec'
  require 'yaml'
  require 'cartodb-rb-client'
  require 'cartodb-rb-client/cartodb'
  require 'active_support/core_ext/array/random_access.rb'

  cartodb_config = {
    'host'         => 'https://cartodb-rb-client.cartodb.com',
    'oauth_key'    => ENV['CARTODB_OAUTH_KEY'],
    'oauth_secret' => ENV['CARTODB_OAUTH_SECRET'],
    'username'     => ENV['CARTODB_USERNAME'],
    'password'     => ENV['CARTODB_PASSWORD']
  }

  if File.exists?("#{File.dirname(__FILE__)}/support/cartodb_config.yml")
    cartodb_config = YAML.load_file("#{File.dirname(__FILE__)}/support/cartodb_config.yml")
  end
  CartoDB::Settings = cartodb_config
  CartoDB::Connection = CartoDB::Client::Connection::Base.new unless defined? CartoDB::Connection
  # CartoDB::Settings = YAML.load_file("#{File.dirname(__FILE__)}/support/database.yml") unless defined? CartoDB::Settings
  # CartoDB::Connection = CartoDB::Client::Connection::Base.new unless defined? CartoDB::Connection

  RgeoFactory = ::RGeo::Geographic.spherical_factory(:srid => 4326)

  require "#{File.dirname(__FILE__)}/support/cartodb_helpers.rb"
  require "#{File.dirname(__FILE__)}/support/cartodb_factories.rb"

  require 'vcr'
  VCR.configure do |c|
    c.default_cassette_options = { :record => :new_episodes }
    c.cassette_library_dir = 'spec/fixtures/cassettes'
    c.hook_into :typhoeus
    #c.preserve_exact_body_bytes
    c.configure_rspec_metadata!
  end

  RSpec.configure do |config|
    config.before(:each) do
      VCR.use_cassette('clean tables') do
        drop_all_cartodb_tables
      end
    end

    config.after(:all) do
      VCR.use_cassette('clean tables') do
        drop_all_cartodb_tables
      end
    end

  end
end

Spork.each_run do
  # This code will be run each time you run your specs.

end

# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.




