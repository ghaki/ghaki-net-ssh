############################################################################
require 'delegate'
require 'forwardable'
require 'net/ssh'
require 'net/ssh/telnet'
require 'ghaki/net_ssh/shell'

############################################################################
module Ghaki
  module NetSSH
    class Telnet < DelegateClass(::Net::SSH::Telnet)
      extend Forwardable

      ########################################################################
      attr_accessor :raw_telnet, :shell, :auto_close
      def_delegators :@shell,
        :log_command_on,  :log_output_on,  :log_all_on,
        :log_command_off, :log_output_off, :log_all_off,
        :log_exec!, :log_command!

      def self.args_to_tel_opts args
        case args.length
        when 2
          return Hash.new
        when 1, 3
          return args.last[:telnet_options] || {}
        else
          raise ArgumentError, "Invalid Arguments Passed: (1..3) != #{args.length}"
        end
      end

      ########################################################################
      def self.start *args, &block
        tel_opt = args_to_tel_opts( args )
        gak_ssh = Shell.start( *args )
        gak_tel = Telnet.new( gak_ssh, tel_opt )
        gak_tel.auto_close = true
        if block_given?
          begin
            block.call( gak_tel )
          ensure
            gak_tel.close
          end
        else
          return gak_tel
        end
      end

      ########################################################################
      def auto_close?
        @auto_close
      end

      ########################################################################
      def close
        super
        @shell.close if @auto_close
      end

      ########################################################################
      def initialize ssh, in_opts={}
        @auto_close = false
        @shell = ssh
        out_opts = in_opts.dup
        out_opts['Session'] = @shell.raw_ssh
        @raw_telnet = ::Net::SSH::Telnet.new(out_opts)
        super @raw_telnet
      end

      ########################################################################
      def exec! cmd
        log_exec!( 'TELNET', cmd ) do
          @raw_telnet.cmd( cmd )
        end
      end

    end # class
  end # namespace
end # package
############################################################################
