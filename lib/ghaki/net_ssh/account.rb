############################################################################
require 'ghaki/account/base'
require 'ghaki/net_ssh/shell'

############################################################################
module Ghaki
  module NetSSH
    class Account < Ghaki::Account::Base

      def start_shell opts={}, &block
        Ghaki::NetSSH::Shell.start \
          opts.merge( :account => self, &block )
      end

      def start_ftp opts={}, &block
        Ghaki::NetSSH::FTP.start \
          opts.merge( :account => self, &block )
      end

      def start_telnet opts={}, &block
        Ghaki::NetSSH::Telnet.start \
          opts.merge( :account => self, &block )
      end

    end # class
  end # namespace
end # package
############################################################################
