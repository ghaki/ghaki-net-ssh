############################################################################
require 'net/ssh'
require 'net/ssh/telnet'
require 'net/sftp'

require 'ghaki/account/base'
require 'ghaki/core_ext/file/with_temp'

require 'ghaki/net_ssh/errors'
require 'ghaki/net_ssh/ftp'
require 'ghaki/net_ssh/logger'
require 'ghaki/net_ssh/telnet'


############################################################################
module Ghaki
  module NetSSH
    class Shell < DelegateClass(::Net::SSH)
      include Ghaki::NetSSH::Logger

      ######################################################################
      DEF_TIMEOUT = 30
      DEF_AUTH_METHODS = %w{
        password
        keyboard-interactive
        publickey
        hostbased
      }

      ######################################################################
      protected
      ######################################################################

      ######################################################################
      def self.raw_opts_log cur_opts, raw_opts
        if cur_opts.has_key?(:logger)
          if cur_opts[:logger].nil?
            # doesn't handle nil correctly
            raw_opts.delete(:logger)
          else
            # anything over WARN is insane
            raw_opts[:logger] = cur_opts[:logger].dup
            cur_opts[:logger].level = ::Logger::WARN
          end
        end
        raw_opts
      end

      ######################################################################
      def self.raw_opts_setup cur_opts
        raw_opts = raw_opts_log( cur_opts, cur_opts.dup )
        raw_opts[:timeout] ||= DEF_TIMEOUT
        raw_opts[:auth_methods] ||= DEF_AUTH_METHODS
        raw_opts.delete(:log_ssh_output)
        raw_opts.delete(:log_ssh_command)
        raw_opts.delete(:account)
        unless cur_opts[:account].password.nil?
          raw_opts[:password] = cur_opts[:account].password
        end
        raw_opts
      end

      ######################################################################
      def self.args_to_opts args
        case args.length
        when 2
          return Hash.new
        when 1, 3
          return args.pop
        else
          raise ArgumentError, "Invalid Arguments Passed: (1..3) != #{args.length}"
        end
      end

      ######################################################################
      def self.args_to_account args, cur_opts
        if args.length == 0
          acc = Ghaki::Account::Base.from_opts cur_opts
        else
          acc = Ghaki::Account::Base.new \
            :hostname => args.shift,
            :username => args.shift
          acc.password = Ghaki::Account::Password.from_opts(cur_opts)
        end
        raise ArgumentError, 'Missing Hostname' if acc.hostname.nil?
        raise ArgumentError, 'Missing Username' if acc.username.nil?
        acc.collapse_opts(cur_opts)
        acc
      end

      public

      ######################################################################
      def self.start *args
        cur_opts = args_to_opts( args )
        acc = args_to_account( args, cur_opts )
        raw_opts = raw_opts_setup( cur_opts )
        raw_ssh = ::Net::SSH.start( acc.hostname, acc.username, raw_opts )
        cur_ssh = Ghaki::NetSSH::Shell.new( raw_ssh, cur_opts )
        if block_given?
          begin yield cur_ssh ensure cur_ssh.close end
        else
          return cur_ssh
        end
      rescue ::Net::SSH::HostKeyMismatch
        $!.remember_host!
        retry
      end

      ######################################################################
      attr_accessor :raw_ssh, :account

      ######################################################################
      def initialize obj, opts={}
        setup_logger opts
        @account = opts[:account]
        @raw_ssh = obj
        super obj
      end

      ######################################################################
      def sftp
        ftp_raw = @raw_ssh.sftp
        ftp_obj = Ghaki::NetSSH::FTP.new( ftp_raw, {
          :account => @account,
          :logger  => @logger,
          :log_ssh_output  => @should_log_output,
          :log_ssh_command => @should_log_command,
        })
        return ftp_obj unless block_given?
        yield ftp_obj
      end

      ######################################################################
      def telnet
        tel_raw = ::Net::SSH::Telnet.new( 'Session' => @raw_ssh )
        tel_obj = Ghaki::NetSSH::Telnet.new( tel_raw, {
          :account => @account,
          :logger  => @logger,
          :log_ssh_output  => @should_log_output,
          :log_ssh_command => @should_log_command,
        })
        return tel_obj unless block_given?
        begin
          yield tel_obj
        ensure
          tel_obj.close
        end
      end

      ######################################################################
      def exec! cmd
        self.log_exec! 'SSH', cmd do
          @raw_ssh.exec!( cmd )
        end
      end

      ######################################################################
      def remove! rem_file
        sftp.remove! rem_file
      end

      ######################################################################
      def upload! loc_file, rem_file
        sftp.upload! loc_file, rem_file
      end

      ######################################################################
      def download! rem_file, loc_file
        sftp.download! rem_file, loc_file
      end

      ######################################################################
      def discover cmd, rx_pairs
        return rx_pairs.match_lines( self.exec!(cmd).split("\n") ) do
          raise RemoteCommandError, 'SSH Discovery Output Not Matched'
        end
      end

      ######################################################################
      def redirect rem_file, loc_file, &block
        sftp do |ftp|
          ftp.remove! rem_file
          out = block.call
          ftp.download! rem_file, loc_file
          out
        end
      end

    end # class
  end # namespace
end # package
############################################################################
