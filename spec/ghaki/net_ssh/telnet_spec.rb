############################################################################
require 'ghaki/logger/base'
require 'ghaki/account/base'
require 'ghaki/net_ssh/telnet'

############################################################################
module Ghaki module NetSSH module TelnetTesting
  describe Telnet do

    ########################################################################
    ACCOUNT = Ghaki::Account::Base.new \
      :hostname => 'host',
      :username => 'user',
      :password => 'secret'

    #-----------------------------------------------------------------------
    def make_log
      mod = Ghaki::Logger::Base
      @logger = flexmock(mod.to_s)
      flexmock( :safe, mod ) do |fm|
        fm.should_receive(:new).and_return(@logger)
      end
      @logger.should_ignore_missing
      @test_opts = {
        :account => ACCOUNT,
        :logger => @logger,
      }
    end

    #-----------------------------------------------------------------------
    def make_ssh_raw
      mod = ::Net::SSH
      @ssh_raw = flexmock(mod.to_s)
      flexmock( :safe, mod ) do |fm|
        fm.should_receive(:start).and_return(@ssh_raw)
      end
      @ssh_raw.should_receive(:close)
    end

    #-----------------------------------------------------------------------
    def make_tel_raw
      mod = ::Net::SSH::Telnet
      @tel_raw = flexmock(mod.to_s)
      flexmock( :safe, mod ) do |fm|
        fm.should_receive(:new).and_return(@tel_raw)
      end
      @tel_raw.should_receive(:close)
    end

    ########################################################################
    before(:each) do
      make_log
      make_ssh_raw
      make_tel_raw
    end

    ########################################################################
    context 'class' do
      subject { Telnet }
      it { should respond_to :start }
      describe '#start' do
        it 'should yield telnet' do
          Telnet.start(@test_opts) do |tel|
            tel.should be_an_instance_of(Telnet)
          end
        end
        it 'should return telnet' do
          tel = Telnet.start(@test_opts)
          tel.should be_an_instance_of(Telnet)
          tel.close
        end
      end
    end

    ########################################################################
    context 'object' do

      before(:each) do
        @tel_gak = Telnet.start(@test_opts)
      end
      subject { @tel_gak }

      context 'logging delegates' do
        [ :log_command_on,  :log_output_on,  :log_all_on,
          :log_command_off, :log_output_off, :log_all_off,
          :log_exec!, :log_command!,
        ].each do |token|
          it { should respond_to token }
        end
      end

      it { should respond_to :exec! }

      describe '#exec!' do
        it 'should delegate to telnet' do
          @tel_raw.should_receive(:cmd).with('who').and_return('moo')
          @tel_gak.exec!('who').should == 'moo'
        end
      end

    end

  end
end end end
############################################################################
