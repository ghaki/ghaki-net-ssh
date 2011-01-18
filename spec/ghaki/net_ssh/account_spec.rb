############################################################################
require 'ghaki/net_ssh/account'

############################################################################
module Ghaki module NetSSH module AccountTesting
  describe Account do

    ########################################################################
    subject do
      Account.new \
        :username => 'user',
        :hostname => 'host',
        :password => 'secret'
    end

    ########################################################################
    context 'objects' do
      context 'basic includes' do
        it { should respond_to :hostname }
      end
      it { should respond_to :start_ftp }
      it { should respond_to :start_shell }
      it { should respond_to :start_telnet }
    end

    ########################################################################
    context 'methods' do

      describe '#start_shell' do
        it 'should create shell connection' do
          Ghaki::NetSSH::Shell.should_receive(:start).with({:account => subject}).and_return(true)
          subject.start_shell.should be_true
        end
      end

      describe '#start_ftp' do
        it 'should create ftp connection' do
          Ghaki::NetSSH::FTP.should_receive(:start).with({:account => subject}).and_return(true)
          subject.start_ftp.should be_true
        end
      end

      describe '#start_telnet' do
        it 'should create telnet connection' do
          Ghaki::NetSSH::Telnet.should_receive(:start).with({:account => subject}).and_return(true)
          subject.start_telnet.should be_true
        end
      end

    end

  end
end end end
############################################################################
