require 'ghaki/net_ssh/ftp'
require 'ghaki/net_ssh/common_helper'

module Ghaki module NetSSH module FTP_Testing
describe FTP do
  include CommonHelper

  before(:each) do
    setup_common
  end

  context 'class' do
    subject { FTP }
    describe '#start' do
      it 'should yield ftp' do
        @ssh_raw.expects(:close).once
        FTP.start(@test_opts) do |sftp| 
          sftp.should be_an_instance_of(FTP)
        end
      end
      it 'should return ftp' do
        @ssh_raw.expects(:close).once
        sftp = FTP.start(@test_opts)
        sftp.should be_an_instance_of(FTP)
        sftp.close
      end
    end
  end

  context 'object' do

    before(:each) do
      @ftp_gak = FTP.start(@test_opts)
    end
    subject { @ftp_gak }

    context 'logging delegates' do
      [ :log_command_on,  :log_output_on,  :log_all_on,
        :log_command_off, :log_output_off, :log_all_off,
        :log_exec!, :log_command!,
      ].each do |token|
        it { should respond_to token }
      end
    end

    describe '#remove!' do
      it 'should delegate remove' do
        @ftp_raw.expects(:remove!).with('remote_file')
        @ftp_gak.remove! 'remote_file'
      end
    end

    describe '#upload!' do
      it 'should delegate upload, rename, and remove' do
        seq = sequence('uploader')
        src = 'local_file'; dst = 'remote_file'
        @ftp_raw.expects(:upload!).with(src,is_a(String)).in_sequence(seq)
        @ftp_raw.expects(:rename!).with(is_a(String),dst).in_sequence(seq)
        @ftp_raw.expects(:remove!).with(is_a(String)).in_sequence(seq)
        @ftp_gak.upload! src, dst
      end
    end

    describe '#download!' do
      it 'should delegate download' do
        src = 'remote_file'; dst = 'local_file'; tmp = 'tmp_file'
        ::File.expects(:with_named_temp).yields(tmp)
        @ftp_raw.expects(:download!).with(src,tmp)
        @ftp_gak.download! src, dst
      end
    end
  end

end
end end end
