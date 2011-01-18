############################################################################
require 'delegate'
require 'net/ssh'
require 'net/sftp'
require 'ghaki/core_ext/file/with_temp'
require 'ghaki/net_ssh/logger'


############################################################################
module Ghaki
  module NetSSH
    class FTP < DelegateClass(::Net::SFTP)

      ######################################################################
      include Ghaki::NetSSH::Logger

      ######################################################################
      attr_accessor :raw_ftp, :account

      ######################################################################
      def self.start *args
        raise NotImplementedError, 'TO_DO'
      end

      ######################################################################
      def initialize obj, opts={}
        setup_logger opts
        @account = opts[:account]
        @raw_ftp = obj
        super(@raw_ftp)
      end

      ######################################################################
      def remove! fname
        begin
          self.log_command! 'SFTP', "remove #{fname}"
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
        self.log_command! 'SFTP', "upload #{loc_file}, #{tmp_file}"
        @raw_ftp.upload! loc_file, tmp_file
        self.log_command! 'SFTP', "rename #{tmp_file}, #{rem_file}"
        @raw_ftp.rename! tmp_file, rem_file
      ensure
        self.log_command! 'SFTP', "remove #{tmp_file}"
        self.remove! tmp_file
      end

      ######################################################################
      def download! rem_file, loc_file
        self.log_command! 'SFTP', "download #{rem_file}, #{loc_file}"
        File.with_named_temp loc_file do |tmp_file|
          @raw_ftp.download! rem_file, tmp_file
        end
      end

    end # class
  end # namespace
end # package
############################################################################
