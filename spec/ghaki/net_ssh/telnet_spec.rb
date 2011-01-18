############################################################################
require 'ghaki/account/base'
require 'ghaki/net_ssh/telnet'

############################################################################
module Ghaki module NetSSH module TelnetTesting
  describe Telnet do

    ########################################################################
    before(:all) do
      @account = Ghaki::Account::Base.new \
        :hostname => 'host',
        :username => 'user',
        :password => 'secret'
      @mock_log = flexmock()
      flexmock( :safe, Ghaki::Logger::Base ) do |fm|
        fm.should_receive(:new).and_return(@mock_log)
      end
      @mock_log.should_ignore_missing
    end

    ########################################################################
    context 'class object' do
      subject { Telnet }
      it { should respond_to :start }
    end

    ########################################################################
    context 'class methods' do
      describe '#start' do
        pending
      end
    end

    ########################################################################
    before(:each) do
      @mock_ssh = flexmock()
      flexmock( :safe, ::Net::SSH ) do |fm|
        fm.should_receive(:start).and_return(@mock_ssh)
      end
      @mock_ssh.should_receive(:close)

      @mock_tel = flexmock()
      flexmock( :safe, ::Net::SSH::Telnet ) do |fm|
        fm.should_receive(:new).and_return(@mock_tel)
      end
    end

    ########################################################################
    context 'object' do
      subject { Telnet.start({ :account => @account }) }
      it { should respond_to :exec! }
    end

    ########################################################################
    context 'object methods' do
      describe '#exec!' do
        pending
      end
    end

  end
end end end
############################################################################
