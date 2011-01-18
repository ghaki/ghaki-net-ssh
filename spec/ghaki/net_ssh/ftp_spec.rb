############################################################################
require 'ghaki/account/base'
require 'ghaki/net_ssh/ftp'

############################################################################
module Ghaki module NetSSH module FTP_Testing
  describe FTP do

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
      subject { FTP }
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

      @mock_ftp = flexmock()
      flexmock( :safe, ::Net::SFTP ) do |fm|
        fm.should_receive(:new).and_return(@mock_ftp)
      end
    end

    ########################################################################
    context 'object' do
      subject { FTP.start({ :account => @account }) }
      it { should respond_to :remove! }
      it { should respond_to :upload! }
      it { should respond_to :download! }
    end

    ########################################################################
    context 'object methods' do
      describe '#remove!' do
        pending
      end
      describe '#upload!' do
        pending
      end
      describe '#download!' do
        pending
      end
    end

  end
end end end
############################################################################
