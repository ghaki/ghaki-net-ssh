############################################################################
require 'delegate'
require 'net/ssh'
require 'net/ssh/telnet'
require 'ghaki/net_ssh/logger'

############################################################################
module Ghaki
  module NetSSH
    class Telnet < DelegateClass(::Net::SSH::Telnet)
      include Ghaki::NetSSH::Logger

      ########################################################################
      attr_accessor :raw_telnet, :account

      ########################################################################
      def self.start *args
        raise NotImplementedError, 'TO_DO'
      end

      ########################################################################
      def initialize obj, opts={}
        setup_logger opts
        @account = opts[:account]
        @raw_telnet = obj
        super obj
      end

      ########################################################################
      def exec! cmd
        self.log_exec! 'TELNET', cmd do
          @raw_telnet.cmd( cmd )
        end
      end

    end # class
  end # namespace
end # package
############################################################################
