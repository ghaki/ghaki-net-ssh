############################################################################
require 'ghaki/account/base'
require 'ghaki/net_ssh/shell'
require 'ghaki/matcher/rx_pairs'

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
      @logger = flexmock()
      flexmock( :safe, Ghaki::Logger::Base ) do |f|
        f.should_receive(:new).
          and_return(@logger)
      end
      @logger.should_ignore_missing
    end

    ########################################################################
    def make_ssh_mock
      @ssh_mock = flexmock()
      flexmock( :safe, ::Net::SSH ) do |f|
        f.should_receive(:start).
          and_return(@ssh_mock)
      end
    end

    ########################################################################
    def clear_ssh
      make_mock_log
      @ssh_mock_opts = {
        :password => PASS,
      }
      @test_ssh_opts = {
        :account => ACCOUNT,
        :logger => @logger,
      }
      make_ssh_mock
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
    context 'class methods' do

      #---------------------------------------------------------------------
      describe '#start' do
        it 'should return ssh' do
          ssh = Shell.start(@test_ssh_opts)
          ssh.should be_an_instance_of(Shell)
        end
        it 'should yield ssh' do
          @ssh_mock.should_receive(:close)
          Shell.start(@test_ssh_opts) do |ssh|
            ssh.should be_an_instance_of(Shell)
          end
        end
      end

    end

    ########################################################################
    context 'object' do
      subject { Shell.new @test_ssh_opts }
      %w{ exec!
          sftp telnet
          remove! upload! download!
          discover redirect
      }.each do |name|
        it { should respond_to name.to_sym }
      end
    end

    ########################################################################
    context 'methods' do

      #---------------------------------------------------------------------
      describe '#exec!' do
        it 'should delegate' do
          @logger.should_receive(:liner).with_any_args.zero_or_more_times()
          @logger.should_receive(:puts).with('SSH host : who').ordered
          @ssh_mock.should_receive(:exec!).with('who').and_return('nobody').ordered
          @logger.should_receive(:reindent).with('nobody').ordered
          @ssh_mock.should_receive(:close).ordered
          Shell.start(@test_ssh_opts) do |ssh|
            ssh.exec! 'who'
          end
        end
      end

      
      #---------------------------------------------------------------------
      describe '#telnet' do
        before(:each) do
          @tel_mock = flexmock()
          flexmock( :safe, ::Net::SSH::Telnet ) do |fm|
            fm.should_receive(:new).and_return(@tel_mock)
          end
          @tel_mock.should_receive(:close).ordered
          @ssh_mock.should_receive(:close).ordered
        end
        it 'should create telnet' do
          Shell.start(@test_ssh_opts) do |ssh|
            ssh.telnet.should be_an_instance_of(Ghaki::NetSSH::Telnet)
          end
        end
        it 'should yield telnet' do
          Shell.start(@test_ssh_opts) do |ssh|
            ssh.telnet do |tel|
              tel.should be_an_instance_of(Ghaki::NetSSH::Telnet)
            end
          end
        end
      end

      ######################################################################
      context 'ftp related helpers' do

        before(:each) do
          @ftp_mock = flexmock()
          @ssh_mock.should_receive(:sftp).and_return(@ftp_mock).ordered
          @ssh_mock.should_receive(:close).ordered
          @ssh_real = Shell.start(@test_ssh_opts)
        end

        #-----------------------------------------------------------------
        describe '#sftp' do
          it 'should create ftp' do
            @ssh_real.sftp.should be_an_instance_of(Ghaki::NetSSH::FTP)
          end
          it 'should yield ftp' do
            @ssh_real.sftp do |ftp|
              ftp.should be_an_instance_of(Ghaki::NetSSH::FTP)
            end
          end
        end

        #-----------------------------------------------------------------
        describe '#remove!' do
          it 'should delegate' do
            @ftp_mock.should_receive(:remove!).with('remote_file')
            @ssh_real.remove! 'remote_file'
          end
        end

        #-----------------------------------------------------------------
        describe '#upload!' do
          it 'should delegate' do
            @ftp_mock.should_receive(:upload!).with('local_file',String)
            @ftp_mock.should_receive(:rename!).with(String,'remote_file')
            @ftp_mock.should_receive(:remove!).with(String)
            @ssh_real.upload! 'local_file', 'remote_file'
          end
        end

        #-------------------------------------------------------------------
        describe '#download!' do
          it 'should delegate' do
            flexmock(:safe, ::File ) do |fm|
              fm.should_receive(:with_named_temp).and_yield('tmp_file')
            end
            @ftp_mock.should_receive(:download!).with('remote_file','tmp_file')
            @ssh_real.download! 'remote_file', 'local_file'
          end
        end

        #-------------------------------------------------------------------
        describe '#redirect' do
          it 'should delegate' do
            flexmock(:safe, ::File ) do |fm|
              fm.should_receive(:with_named_temp).and_yield('tmp_file')
            end
            @ftp_mock.should_receive(:remove!).with('remote_file')
            @ftp_mock.should_receive(:download!).with('remote_file','tmp_file')

            out = @ssh_real.redirect 'remote_file', 'local_file' do
              'output'
            end
            out.should == 'output'
          end
        end

      end

      #---------------------------------------------------------------------
      describe '#discover' do
        before(:each) do
          @matcher = Ghaki::Matcher::RxPairs.new({
            %r{foo}o => :foo,
          })
          @ssh_mock.should_receive(:close).ordered
          @ssh_real = Shell.start(@test_ssh_opts)
        end
        it 'should match if found' do
          @ssh_mock.should_receive(:exec!).with('who').and_return('foo')
          @ssh_real.discover( 'who', @matcher ).should == :foo
        end
        it 'should reject if not found' do
          lambda do
            @ssh_mock.should_receive(:exec!).with('who').and_return('bar')
            @ssh_real.discover( 'who', @matcher )
          end.should raise_error(RemoteCommandError)
        end
      end

    end

  end
end end end
############################################################################
