############################################################################
require 'ghaki/net_ssh/shell'
require 'ghaki/matcher/rx_pairs'

require 'mocha_helper'
require 'ghaki/net_ssh/common_helper'

############################################################################
module Ghaki module NetSSH module ShellTesting
  describe Shell do

    before(:each) do
      setup_common
    end

    ########################################################################
    context 'class' do
      subject { Shell }
      it { should respond_to :start }

      describe '#start' do

        it 'should return ssh' do
          subject.start(@test_opts).should be_an_instance_of(Shell)
        end

        it 'should yield ssh' do
          @ssh_raw.expects(:close).once
          subject.start(@test_opts) do |ssh|
            ssh.should be_an_instance_of(Shell)
          end
        end

      end
    end

   ########################################################################
   context 'object' do

      before(:each) do
        @ssh_gak = Shell.start(@test_opts)
      end
      subject { @ssh_gak }

      it { should respond_to :discover }
      it { should respond_to :download! }
      it { should respond_to :exec! }
      it { should respond_to :redirect }
      it { should respond_to :remove! }
      it { should respond_to :sftp }
      it { should respond_to :telnet }
      it { should respond_to :upload! }

      #---------------------------------------------------------------------
      describe '#exec!' do
        it 'should delegate' do
          @ssh_raw.expects(:exec!).with('who').returns('nobody')
          @ssh_gak.exec! 'who'
        end
      end
      
      #---------------------------------------------------------------------
      describe '#telnet' do
        it 'should create telnet' do
          tel = @ssh_gak.telnet
          tel.should be_an_instance_of(Telnet)
        end
        it 'should yield telnet' do
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
        it 'should match if found' do
          @ssh_raw.expects(:exec!).with('who').returns('foo')
          @ssh_gak.discover( 'who', @matcher ).should == :foo
        end
        it 'should reject if not found' do
          lambda do
            @ssh_raw.expects(:exec!).with('who').returns('bar')
            @ssh_gak.discover( 'who', @matcher )
          end.should raise_error(RemoteCommandError)
        end
      end

      #-----------------------------------------------------------------
      describe '#sftp' do
        it 'should create ftp' do
          ftp = @ssh_gak.sftp
          ftp.should be_an_instance_of(FTP)
        end
        it 'should yield ftp' do
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


        #-----------------------------------------------------------------
        describe '#remove!' do
          it 'should delegate to ftp' do
            trg = 'remote_file'
            @ftp_gak.expects(:remove!).with(trg)
            @ssh_gak.remove! trg
          end
        end

        #-----------------------------------------------------------------
        describe '#upload!' do
          it 'should delegate to ftp' do
            src,dst = 'local_file', 'remote_file'
            @ftp_gak.expects(:upload!).with(src,dst)
            @ssh_gak.upload! src, dst
          end
        end

        #-------------------------------------------------------------------
        describe '#download!' do
          it 'should delegate to ftp' do
            src,dst = 'remote_file', 'local_file'
            @ftp_gak.expects(:download!).with(src,dst)
            @ssh_gak.download! src, dst
          end
        end

        #-------------------------------------------------------------------
        describe '#redirect' do
          it 'should delegate to ftp' do
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
############################################################################
