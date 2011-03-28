############################################################################
require 'mocha_helper'
require 'ghaki/net_ssh/common_helper'
require 'ghaki/net_ssh/account'

############################################################################
module Ghaki module NetSSH module AccountTesting
  describe Account do
    
    before(:each) do
      setup_common
      @account = Ghaki::NetSSH::Account.new(@user_opts)
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
          Ghaki::NetSSH::Shell.expects(:start).
            with( :account => subject ).returns(:shell_started)
          subject.start_shell.should == :shell_started
        end
      end

      #---------------------------------------------------------------------
      describe '#start_ftp' do
        it 'should create ftp connection' do
          Ghaki::NetSSH::FTP.expects(:start).
            with( :account => subject ).returns(:sftp_started)
          subject.start_ftp.should == :sftp_started
        end
      end

      #---------------------------------------------------------------------
      describe '#start_telnet' do
        it 'should create telnet connection' do
          Ghaki::NetSSH::Telnet.expects(:start).
            with( :account => subject ).returns(:telnet_started)
          subject.start_telnet.should == :telnet_started
        end
      end

    end

  end
end end end
############################################################################
