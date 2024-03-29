require 'delegate'
require 'forwardable'
require 'net/ssh'
require 'net/sftp'
require 'ghaki/core_ext/file/with_temp'
require 'ghaki/net_ssh/shell'

module Ghaki  #:nodoc:
module NetSSH #:nodoc:

class FTP < DelegateClass(::Net::SFTP)
  extend Forwardable

  attr_accessor :raw_ftp, :shell
  def_delegators :@shell,
    :log_command_on,  :log_output_on,  :log_all_on,
    :log_command_off, :log_output_off, :log_all_off,
    :log_exec!, :log_command!

  def self.start *args
    ssh_gak = Ghaki::NetSSH::Shell.start( *args )
    ftp_gak = Ghaki::NetSSH::FTP.new( ssh_gak )
    if block_given?
      begin
        yield ftp_gak
      ensure
        ssh_gak.close
      end
    else
      return ftp_gak
    end
  end

  def close
    @shell.close
  end

  def initialize ssh
    @shell = ssh
    @raw_ftp = @shell.raw_ssh.sftp
    super(@raw_ftp)
  end

  def remove! fname
    begin
      log_command! 'SFTP', "remove #{fname}"
      @raw_ftp.remove! fname
    rescue ::Net::SFTP::StatusException
      raise unless $!.message =~ %r{ \b no \s such \s file \b }oix
    end
  end

  def upload! loc_file, rem_file
    tmp_file = ::File.join( ::File.dirname(rem_file),
      '_tmp_' + $$.to_s + '.' + ::File.basename(rem_file) )
    log_command! 'SFTP', "upload #{loc_file}, #{tmp_file}"
    @raw_ftp.upload! loc_file, tmp_file
    log_command! 'SFTP', "rename #{tmp_file}, #{rem_file}"
    @raw_ftp.rename! tmp_file, rem_file
  ensure
    self.remove! tmp_file
  end

  def download! rem_file, loc_file
    log_command! 'SFTP', "download #{rem_file}, #{loc_file}"
    File.with_named_temp loc_file do |tmp_file|
      @raw_ftp.download! rem_file, tmp_file
    end
  end

end
end end
