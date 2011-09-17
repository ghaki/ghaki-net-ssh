require 'ghaki/net_ssh/shell'
require 'ghaki/net_ssh/common_helper'
require 'ghaki/matcher/rx_pairs'

module Ghaki module NetSSH module Shell_Testing
describe Shell do
  include CommonHelper

  before(:each) do
    setup_common
  end

  context 'eigen class' do
    subject { Shell }

    describe '#start' do
      it 'returns ssh' do
        subject.start(@test_opts).should be_an_instance_of(Shell)
      end
      it 'yields ssh' do
        @ssh_raw.expects(:close).once
        subject.start(@test_opts) do |ssh|
          ssh.should be_an_instance_of(Shell)
        end
      end
      it 'handles password retries' do
        @account.passwords = ['invalid','secret']
        ::Net::SSH.expects(:start).raises(::Net::SSH::AuthenticationFailed).then.returns(@ssh_raw)
        @logger.expects(:warn).with(regexp_matches(%r{failed\spassword\sattempt}))
        subject.start(@test_opts).should be_an_instance_of(Shell)
        @account.failed_passwords?.should be_true
      end
    end

  end

  context 'object instance' do
    before(:each) do
      @ssh_gak = Shell.start(@test_opts)
    end
    subject { @ssh_gak }

    describe '#exec!' do
      it 'delegates to ssh' do
        @ssh_raw.expects(:exec!).with('who').returns('nobody')
        @ssh_gak.exec! 'who'
      end
    end
    
    describe '#telnet' do
      it 'creates telnet' do
        tel = @ssh_gak.telnet
        tel.should be_an_instance_of(Telnet)
      end
      it 'yields telnet' do
        @tel_raw.expects(:close).once
        @ssh_gak.telnet do |tel|
          tel.should be_an_instance_of(Telnet)
        end
      end
    end

    describe '#discover' do
      before(:each) do
        @matcher = Ghaki::Matcher::RxPairs.new({
          %r{foo}o => :foo,
        })
      end
      it 'matches if found' do
        @ssh_raw.expects(:exec!).with('who').returns('foo')
        @ssh_gak.discover( 'who', @matcher ).should == :foo
      end
      it 'rejects if not found' do
        lambda do
          @ssh_raw.expects(:exec!).with('who').returns('bar')
          @ssh_gak.discover( 'who', @matcher )
        end.should raise_error(RemoteCommandError)
      end
    end

    describe '#sftp' do
      it 'creates ftp' do
        ftp = @ssh_gak.sftp
        ftp.should be_an_instance_of(FTP)
      end
      it 'yields ftp' do
        @ssh_gak.sftp do |ftp|
          ftp.should be_an_instance_of(FTP)
        end
      end
    end

    ####################################################################
    describe 'sftp helpers' do

      before(:each) do
        @ftp_gak = mock('Ghaki::NetSSH::FTP')
        FTP.stubs( :new => @ftp_gak )
      end

      describe '#remove!' do
        it 'delegates to ftp' do
          trg = 'remote_file'
          @ftp_gak.expects(:remove!).with(trg)
          @ssh_gak.remove! trg
        end
      end

      describe '#upload!' do
        it 'delegates to ftp' do
          src,dst = 'local_file', 'remote_file'
          @ftp_gak.expects(:upload!).with(src,dst)
          @ssh_gak.upload! src, dst
        end
      end

      describe '#download!' do
        it 'delegates to ftp' do
          src,dst = 'remote_file', 'local_file'
          @ftp_gak.expects(:download!).with(src,dst)
          @ssh_gak.download! src, dst
        end
      end

      describe '#redirect' do
        it 'delegates to ftp' do
          src,dst = 'remote_file', 'local_file'
          put = 'output'
          @ftp_gak.expects(:remove!).with(src)
          @ftp_gak.expects(:download!).with(src,dst)
          @ssh_gak.redirect(src,dst) do put end.should == put
        end
      end
    end

  end
end
end end end
