############################################################################
require 'delegate'
require 'net/ssh'
require 'net/sftp'
require 'ghaki/core_ext/file/with_temp'
require 'ghaki/net_ssh/shell'

############################################################################
module Ghaki
  module NetSSH
    class FTP < DelegateClass(::Net::SFTP)

      ######################################################################
      attr_accessor :raw_ftp, :shell

      ######################################################################
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

      ######################################################################
      def close
        @shell.close
      end

      ######################################################################
      def initialize ssh, opts={}
        @shell = ssh
        @raw_ftp = @shell.raw_ssh.sftp
        super(@raw_ftp)
      end

      ######################################################################
      def remove! fname
        begin
          @shell.log_command! 'SFTP', "remove #{fname}"
          @raw_ftp.remove! fname
        rescue ::Net::SFTP::StatusException
          raise unless $!.message =~ %r{ \b no \s such \s file \b }oix
        end
      end

      ######################################################################
      def upload! loc_file, rem_file
        tmp_file = ::File.dirname(rem_file) +
          ::File::Separator + '_tmp_' + $$.to_s + '.' +
          ::File.basename(rem_file)
        @shell.log_command! 'SFTP', "upload #{loc_file}, #{tmp_file}"
        @raw_ftp.upload! loc_file, tmp_file
        @shell.log_command! 'SFTP', "rename #{tmp_file}, #{rem_file}"
        @raw_ftp.rename! tmp_file, rem_file
      ensure
        @shell.log_command! 'SFTP', "remove #{tmp_file}"
        self.remove! tmp_file
      end

      ######################################################################
      def download! rem_file, loc_file
        @shell.log_command! 'SFTP', "download #{rem_file}, #{loc_file}"
        File.with_named_temp loc_file do |tmp_file|
          @raw_ftp.download! rem_file, tmp_file
        end
      end

    end # class
  end # namespace
end # package
############################################################################
