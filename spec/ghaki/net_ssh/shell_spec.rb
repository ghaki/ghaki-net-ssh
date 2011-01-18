############################################################################
require 'ghaki/account/base'
require 'ghaki/net_ssh/shell'

############################################################################
module Ghaki module NetSSH module ShellTesting
  describe Shell do

    ########################################################################
    HOST = 'host'
    USER = 'user'
    PASS = 'secret'
    ACCOUNT = Ghaki::Account::Base.new \
        :hostname => HOST,
        :username => USER,
        :password => PASS

    ########################################################################
    def make_mock_log
      klass = Ghaki::Log::Base
      mockr = flexmock( klass.to_s )
      flexmock( :safe, klass ) do |m|
        m.should_receive(:new).
          and_return(mockr)
      end
      @logger = mockr
      @logger.should_receive(:level=)
    end

    ########################################################################
    def make_mock_ssh
      klass = ::Net::SSH
      mockr = flexmock( klass.to_s )
      flexmock( :safe, klass ) do |m|
        m.should_receive(:start).
          with(HOST,USER,Hash).
          and_return(mockr)
      end
      @mock_ssh = mockr
    end

    ########################################################################
    def clear_ssh
      make_mock_log
      @mock_ssh_opts = {
        :password => PASS,
      }
      @test_ssh_opts = {
        :account => ACCOUNT,
        :logger => @logger,
      }
      make_mock_ssh
    end

    ########################################################################
    before(:each) do
      clear_ssh
    end

    ########################################################################
    context 'class object' do
      subject { Shell }
      it { should respond_to :start }
    end

    ########################################################################
    context 'object' do
      subject { Shell.new @test_ssh_opts }
      it { should respond_to :exec! }
      it { should respond_to :sftp }
      it { should respond_to :telnet }
      it { should respond_to :remove! }
      it { should respond_to :upload! }
      it { should respond_to :download! }
      it { should respond_to :discover }
      it { should respond_to :redirect }
    end

    ########################################################################
    context 'class methods' do

      #---------------------------------------------------------------------
      describe '#start' do
        it 'should return object' do
          ssh = Shell.start(@test_ssh_opts)
          ssh.should be_an_instance_of(Shell)
        end
        it 'should pass object to block' do
          @mock_ssh.should_receive(:close)
          Shell.start(@test_ssh_opts) do |ssh|
            ssh.should be_an_instance_of(Shell)
          end
        end
      end

    end

    ########################################################################
    context 'methods' do

      #---------------------------------------------------------------------
      describe '#exec!' do
        it 'should delegate' do
          @logger.should_receive(:liner).with_any_args.zero_or_more_times()
          @logger.should_receive(:puts).with('SSH host : who').ordered
          @mock_ssh.should_receive(:exec!).with('who').and_return('nobody').ordered
          @logger.should_receive(:reindent).with('nobody').ordered
          @mock_ssh.should_receive(:close).ordered
          Shell.start(@test_ssh_opts) do |ssh|
            ssh.exec! 'who'
          end
        end
      end

      #---------------------------------------------------------------------
      describe '#sftp' do
        it 'should create ftp' do
          @mock_raw_ftp = flexmock()
          @mock_cur_ftp = flexmock()
          @mock_ssh.should_receive(:sftp).and_return(@mock_raw_ftp)
          flexmock( :safe, Ghaki::NetSSH::FTP ) do |fm|
            fm.should_receive(:new).and_return(@mock_cur_ftp)
          end
          @mock_cur_ftp.should_receive(:upload!)
          @mock_ssh.should_receive(:close).ordered
          Shell.start(@test_ssh_opts) do |ssh|
            ssh.sftp.upload! 'local_file', 'remote_file'
          end
        end
      end
      
      #---------------------------------------------------------------------
      describe '#telnet' do
        it 'should create telnet' do
          @mock_raw_tel = flexmock()
          flexmock( :safe, ::Net::SSH::Telnet ) do |fm|
            fm.should_receive(:new).and_return(@mock_cur_tel)
          end
          @mock_cur_tel = flexmock()
          flexmock( :safe, Ghaki::NetSSH::Telnet ) do |fm|
            fm.should_receive(:new).and_return(@mock_cur_tel)
          end
          @mock_cur_tel.should_receive(:exec!)
          Shell.start(@test_ssh_opts) do |ssh|
            ssh.telnet.exec! 'who'
          end
        end
      end

      describe '#remove!' do
        pending
      end
      describe '#upload!' do
        pending
      end
      describe '#download!' do
        pending
      end
      describe '#discover' do
        pending
      end
      describe '#redirect' do
        pending
      end
    end

  end
end end end
############################################################################
