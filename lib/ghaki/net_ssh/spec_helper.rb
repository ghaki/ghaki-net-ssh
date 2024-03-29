require 'ghaki/net_ssh/shell'
require 'ghaki/logger/spec_helper'

module Ghaki  #:nodoc:
module NetSSH #:nodoc:

module SpecHelper
  include Ghaki::Logger::SpecHelper

  def stub_raw_net_ssh
    @tel_raw = stub_everything('Net::Telnet')
    ::Net::SSH::Telnet.stubs({
      :new => @tel_raw,
    })
    @ssh_raw = stub_everything('Net::SSH')
    ::Net::SSH.stubs({
      :start => @ssh_raw,
    })
    @ftp_raw = stub_everything('Net::SFTP')
    @ssh_raw.stubs({
      :sftp => @ftp_raw,
    })
  end

  def stub_gak_net_ssh
    stub_raw_net_ssh
    @ftp_gak = stub_everything('Ghaki::NetSSH::FTP')
    Ghaki::NetSSH::FTP.stubs({
      :new => @ftp_gak,
    })
    @tel_gak = stub_everything('Ghaki::NetSSH::Telnet')
    Ghaki::NetSSH::Telnet.stubs({
      :new => @tel_gak,
    })
  end

  def clear_safe_gak_net_ssh
    @ssh_gak = nil
  end

  def setup_safe_gak_net_ssh opts={}
    return unless @ssh_gak.nil?
    setup_safe_logger
    stub_gak_net_ssh
    opts[:hostname] ||= 'host'
    opts[:username] ||= 'user'
    opts[:password] ||= 'secret'
    opts[:logger] ||= @logger
    @ssh_gak = Ghaki::NetSSH::Shell.start(opts)
    @ssh_gak.stubs({
      :sftp   => @ftp_gak,
      :telnet => @tel_gak,
    })
    Ghaki::NetSSH::Shell.stubs({
      :new => @ssh_gak,
    })
  end

  def reset_safe_gak_net_ssh opts={}
    clear_safe_gak_net_ssh
    setup_safe_gak_net_ssh opts
  end

end
end end
