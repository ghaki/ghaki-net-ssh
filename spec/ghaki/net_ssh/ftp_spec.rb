############################################################################
require 'ghaki/logger/base'
require 'ghaki/account/base'
require 'ghaki/net_ssh/ftp'

############################################################################
module Ghaki module NetSSH module FTP_Testing
  describe FTP do

    ########################################################################
    ACCOUNT = Ghaki::Account::Base.new \
      :hostname => 'host',
      :username => 'user',
      :password => 'secret'

    ########################################################################
    def make_log
      @logger = flexmock()
      flexmock( :safe, Ghaki::Logger::Base ) do |fm|
        fm.should_receive(:new).and_return(@logger)
      end
      @logger.should_ignore_missing
      @test_opts = {
        :account  => ACCOUNT.dup,
        :logger => @logger,
      }
    end

    ########################################################################
    def make_ssh_raw
      @ssh_raw = flexmock('Net:SSH')
      flexmock( :safe, ::Net::SSH ) do |fm|
        fm.should_receive(:start).and_return(@ssh_raw)
      end
      @ssh_raw.should_receive(:close)
    end

    ########################################################################
    def make_ftp_raw
      @ftp_raw = flexmock('Net::SFTP')
      flexmock( :safe, ::Net::SFTP ) do |fm|
        fm.should_receive(:new).and_return(@ftp_raw)
      end
      @ssh_raw.should_receive(:sftp).and_return(@ftp_raw)
    end

    ########################################################################
    before(:each) do
      make_log
      make_ssh_raw
      make_ftp_raw
    end

    ########################################################################
    context 'class' do
      subject { FTP }

      it { should respond_to :start }

      describe '#start' do
        it 'should yield ftp' do
          FTP.start(@test_opts) do |sftp| 
            sftp.should be_an_instance_of(FTP)
          end
        end
        it 'should return ftp' do
          sftp = FTP.start(@test_opts)
          sftp.should be_an_instance_of(FTP)
        end
      end

    end

    ########################################################################
    context 'object' do

      before(:each) do
        @ftp_gak = FTP.start(@test_opts)
      end

      #-------------------------------------------------------------------
      subject { @ftp_gak }

      context 'logging delegates' do
        [ :log_command_on,  :log_output_on,  :log_all_on,
          :log_command_off, :log_output_off, :log_all_off,
          :log_exec!, :log_command!,
        ].each do |token|
          it { should respond_to token }
        end
      end

      #-------------------------------------------------------------------
      it { should respond_to :remove! }
      describe '#remove!' do
        it 'should delegate remove' do
          @ftp_raw.should_receive(:remove!).with('remote_file')
          @ftp_gak.remove! 'remote_file'
        end
      end

      #-------------------------------------------------------------------
      it { should respond_to :upload! }
      describe '#upload!' do
        it 'should delegate upload, rename, and remove' do
          @ftp_raw.should_receive(:upload!).with('local_file',String)
          @ftp_raw.should_receive(:rename!).with(String,'remote_file')
          @ftp_raw.should_receive(:remove!).with(String)
          @ftp_gak.upload! 'local_file', 'remote_file'
        end
      end

      #-------------------------------------------------------------------
      it { should respond_to :download! }
      describe '#download!' do
        it 'should delegate download' do
          flexmock( :safe, ::File ) do |fm|
            fm.should_receive(:with_named_temp).and_yield('tmp_file')
          end
          @ftp_raw.should_receive(:download!).with('remote_file','tmp_file')
          @ftp_gak.download! 'remote_file', 'local_file'
        end
      end
    end

  end
end end end
############################################################################
