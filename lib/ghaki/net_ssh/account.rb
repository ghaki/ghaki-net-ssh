require 'ghaki/account/base'
require 'ghaki/net_ssh/shell'

module Ghaki  #:nodoc:
module NetSSH #:nodoc:

class Account < Ghaki::Account::Base
  attr_accessor :logger

  def initialize opts={}; super opts
    @logger = opts[:logger]
  end

  def start_shell opts={}, &block
    Ghaki::NetSSH::Shell.start \
      setup_shell_opts(opts), &block
  end

  def start_ftp opts={}, &block
    Ghaki::NetSSH::FTP.start \
      setup_shell_opts(opts), &block
  end

  def start_telnet opts={}, &block
    Ghaki::NetSSH::Telnet.start \
      setup_shell_opts(opts), &block
  end

  protected

  def setup_shell_opts opts
    opts[:account] = self
    opts[:logger] ||= @logger unless @logger.nil?
    opts
  end

end
end end
