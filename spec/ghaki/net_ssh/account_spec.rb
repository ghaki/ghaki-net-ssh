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
      %w{
        hostname
        start_ftp start_shell start_telnet
      }.each do |name|
        it { should respond_to name.to_sym }
      end
    end

    ########################################################################
    context 'methods' do

      #---------------------------------------------------------------------
      describe '#start_shell' do
        it 'should create shell connection' do
          flexmock( :safe, Ghaki::NetSSH::Shell ) do |fm|
            fm.should_receive(:start).
              with( { :account => subject } ).
              and_return(:shell_started)
          end
          subject.start_shell.should == :shell_started
        end
      end

      #---------------------------------------------------------------------
      describe '#start_ftp' do
        it 'should create ftp connection' do
          flexmock( :safe, Ghaki::NetSSH::FTP ) do |fm|
            fm.should_receive(:start).
              with( {:account => subject} ).
              and_return(:sftp_started)
          end
          subject.start_ftp.should == :sftp_started
        end
      end

      #---------------------------------------------------------------------
      describe '#start_telnet' do
        it 'should create telnet connection' do
          flexmock( :safe, Ghaki::NetSSH::Telnet ) do |fm|
            fm.should_receive(:start).
              with( {:account => subject} ).
              and_return(:telnet_started)
          end
          subject.start_telnet.should == :telnet_started
        end
      end

    end

  end
end end end
############################################################################
