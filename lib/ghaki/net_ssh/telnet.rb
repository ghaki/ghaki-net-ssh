############################################################################
require 'delegate'
require 'net/ssh'
require 'net/ssh/telnet'
require 'ghaki/net_ssh/shell'

############################################################################
module Ghaki
  module NetSSH
    class Telnet < DelegateClass(::Net::SSH::Telnet)

      ########################################################################
      attr_accessor :raw_telnet, :shell, :auto_close

      ########################################################################
      def self.start *args, &block
        gak_ssh = Shell.start( *args )
        gak_tel = Telnet.new( gak_ssh )
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
      def initialize ssh, opts={}
        @auto_close = false
        @shell = ssh
        @raw_telnet = ::Net::SSH::Telnet.new( 'Session' => @shell.raw_ssh )
        super @raw_telnet
      end

      ########################################################################
      def exec! cmd
        @shell.log_exec! 'TELNET', cmd do
          @raw_telnet.cmd( cmd )
        end
      end

    end # class
  end # namespace
end # package
############################################################################
