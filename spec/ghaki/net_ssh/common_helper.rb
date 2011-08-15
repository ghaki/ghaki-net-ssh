require 'ghaki/account/base'
require 'ghaki/net_ssh/spec_helper'

module CommonHelper
  include Ghaki::NetSSH::SpecHelper

  def setup_common
    setup_safe_logger
    stub_raw_net_ssh
    @user_opts = {
      :username => 'user',
      :hostname => 'host',
      :password => 'secret',
    }
    @account = Ghaki::Account::Base.new @user_opts
    @test_opts = {
      :account  => @account,
      :logger   => @logger,
    }
  end

end
