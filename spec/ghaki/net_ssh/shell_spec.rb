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
    def make_log
      @logger = flexmock('Ghaki::Logger::Base')
      flexmock( :safe, Ghaki::Logger::Base ) do |f|
        f.should_receive(:new).
          and_return(@logger)
      end
      @logger.should_ignore_missing
      @test_ssh_opts = {
        :account => ACCOUNT,
        :logger => @logger,
      }
    end

    ########################################################################
    def make_ssh_raw
      @ssh_raw = flexmock('Net:SSH')
      flexmock( :safe, ::Net::SSH ) do |f|
        f.should_receive(:start).
          and_return(@ssh_raw)
      end
      @ssh_raw.should_receive(:close)
    end

    ########################################################################
    def make_ssh_gak
      @ssh_gak = Shell.start(@test_ssh_opts)
    end

    ########################################################################
    def make_tel_raw
      @tel_raw = flexmock('Net:SSH::Telnet')
      flexmock( :safe, ::Net::SSH::Telnet ) do |fm|
        fm.should_receive(:new).and_return(@tel_raw)
      end
      @tel_raw.should_receive(:close)
    end

    ########################################################################
    def make_ftp
      @ssh_raw.should_receive(:sftp).and_return(flexmock('Net::SFTP'))
      @ftp_gak = flexmock('Ghaki::NetSSH::FTP')
      flexmock( :safe, Ghaki::NetSSH::FTP ) do |fm|
        fm.should_receive(:new).and_return(@ftp_gak)
      end
    end

    ########################################################################
    before(:each) do
      make_log
      make_ssh_raw
    end

    ########################################################################
    context 'class' do
      subject { Shell }
      it { should respond_to :start }
      describe '#start' do
        it 'should return ssh' do
          ssh = Shell.start(@test_ssh_opts)
          ssh.should be_an_instance_of(Shell)
        end
        it 'should yield ssh' do
          Shell.start(@test_ssh_opts) do |ssh|
            ssh.should be_an_instance_of(Shell)
          end
        end
      end
    end

    ########################################################################
    context 'object' do
      before(:each) do
        make_ssh_gak
      end
      subject { @ssh_gak }

      #---------------------------------------------------------------------
      it { should respond_to :exec! }
      describe '#exec!' do
        it 'should delegate' do
          @ssh_raw.should_receive(:exec!).with('who').and_return('nobody').ordered
          @ssh_gak.exec! 'who'
        end
      end
      
      #---------------------------------------------------------------------
      it { should respond_to :telnet }
      describe '#telnet' do
        before(:each) do
          make_tel_raw
        end
        it 'should create telnet' do
          @ssh_gak.telnet.should be_an_instance_of(Ghaki::NetSSH::Telnet)
        end
        it 'should yield telnet' do
          @ssh_gak.telnet do |tel|
            tel.should be_an_instance_of(Ghaki::NetSSH::Telnet)
          end
        end
      end

      #-----------------------------------------------------------------
      it { should respond_to :sftp }
      describe '#sftp' do
        before(:each) do
          @ssh_raw.should_receive(:sftp).and_return( flexmock('Net::SFTP') )
        end
        it 'should create ftp' do
          @ssh_gak.sftp.should be_an_instance_of(Ghaki::NetSSH::FTP)
        end
        it 'should yield ftp' do
          @ssh_gak.sftp do |ftp|
            ftp.should be_an_instance_of(Ghaki::NetSSH::FTP)
          end
        end
      end

      ######################################################################
      context 'ftp helpers' do
        before(:each) do make_ftp end
        
        #-----------------------------------------------------------------
        it { should respond_to :remove! }
        describe '#remove!' do
          it 'should delegate to ftp' do
            @ftp_gak.should_receive(:remove!).with('remote_file')
            @ssh_gak.remove! 'remote_file'
          end
        end

        #-----------------------------------------------------------------
        it { should respond_to :upload! }
        describe '#upload!' do
          it 'should delegate to ftp' do
            @ftp_gak.should_receive(:upload!).with('local_file','remote_file')
            @ssh_gak.upload! 'local_file', 'remote_file'
          end
        end

        #-------------------------------------------------------------------
        it { should respond_to :download! }
        describe '#download!' do
          it 'should delegate to ftp' do
            @ftp_gak.should_receive(:download!).with('remote_file','local_file')
            @ssh_gak.download! 'remote_file', 'local_file'
          end
        end

        #-------------------------------------------------------------------
        it { should respond_to :redirect }
        describe '#redirect' do
          it 'should delegate to ftp' do
            @ftp_gak.should_receive(:remove!).with('remote_file')
            @ftp_gak.should_receive(:download!).with('remote_file','local_file')
            out = @ssh_gak.redirect 'remote_file', 'local_file' do
              'output'
            end
            out.should == 'output'
          end
        end

      end

      #---------------------------------------------------------------------
      it { should respond_to :discover }
      describe '#discover' do
        before(:each) do
          @matcher = Ghaki::Matcher::RxPairs.new({
            %r{foo}o => :foo,
          })
        end
        it 'should match if found' do
          @ssh_raw.should_receive(:exec!).with('who').and_return('foo')
          @ssh_gak.discover( 'who', @matcher ).should == :foo
        end
        it 'should reject if not found' do
          lambda do
            @ssh_raw.should_receive(:exec!).with('who').and_return('bar')
            @ssh_gak.discover( 'who', @matcher )
          end.should raise_error(RemoteCommandError)
        end
      end

    end

  end
end end end
############################################################################
