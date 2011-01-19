############################################################################
require 'ghaki/logger/base'
require 'ghaki/net_ssh/logger'
require 'ghaki/account/base'

############################################################################
module Ghaki module NetSSH module LoggerTesting
  describe Logger do

    ########################################################################
    class UsingLogger
      include Logger
      attr_accessor :account
      def initialize opts={}
        setup_logger opts
        @account = Ghaki::Account::Base.new \
          :hostname => 'host'
      end
    end

    ########################################################################
    def make_log
      mod = Ghaki::Logger::Base.new
      @logger = flexmock(mod.to_s)
      flexmock( :safe, mod ) do |fm|
        fm.should_receive(:new).and_return(@logger)
      end
      @test_opts = {
        :logger => @logger,
      }
    end

    ########################################################################
    before(:each) do
      make_log
    end

    ########################################################################
    context 'objects including' do

      #---------------------------------------------------------------------
      it { should respond_to :setup_logger }
      describe '#setup_logger'    do
        it 'should accept opt <log_ssh_command>' do
          @subj = UsingLogger.new( :logger => @logger, :log_ssh_command => false )
          @subj.should_log_command.should be_false
        end
        it 'should default opt <log_ssh_command>' do
          @subj = UsingLogger.new( :logger => @logger )
          @subj.should_log_command.should be_true
        end
        it 'should accept opt <log_ssh_output>' do
          @subj = UsingLogger.new( :logger => @logger, :log_ssh_output => false )
          @subj.should_log_output.should be_false
        end
        it 'should default opt <log_ssh_output>' do
          @subj = UsingLogger.new( :logger => @logger )
          @subj.should_log_output.should be_true
        end
      end

      before(:each) do
        @subj = UsingLogger.new(@test_opts)
      end
      subject { @subj }

      #---------------------------------------------------------------------
      it { should respond_to :log_command! }
      describe '#log_command!' do
        it 'should log title, command, and host' do
          @logger.should_receive(:puts).with('SSH host : who').once
          @subj.log_command! 'SSH', 'who'
        end
        it 'should not log when supressed' do
          @subj.should_log_command = false
          @logger.should_receive(:puts).never
          @subj.log_command! 'SSH', 'who'
        end
      end

      #---------------------------------------------------------------------
      it { should respond_to :log_exec! }
      describe '#log_exec!' do
        it 'should log title and output' do
          @logger.should_receive(:puts).with('SSH host : who').once
          @logger.should_receive(:puts).with('output').once
          @logger.should_receive(:liner).twice
          @subj.log_exec!('SSH', 'who') do 'output' end.should == 'output'
        end
        it 'should log only output when command is supressed' do
          @subj.should_log_command = false
          @logger.should_receive(:puts).with('SSH host : who').never
          @logger.should_receive(:puts).with('output').once
          @logger.should_receive(:liner).twice
          @subj.log_exec!('SSH', 'who') do 'output' end.should == 'output'
        end
        it 'should not log when both are supressed' do
          @subj.should_log_command = false
          @subj.should_log_output = false
          @logger.should_receive(:puts).never
          @logger.should_receive(:liner).never
          @subj.log_exec!('SSH', 'who') do 'output' end.should == 'output'
        end
        it 'should default for no output' do
          @subj.should_log_command = false
          @logger.should_receive(:puts).with('** NO OUTPUT **').once
          @logger.should_receive(:liner).never
          @subj.log_exec!('SSH', 'who') do nil end.should == ''
        end
      end

      #---------------------------------------------------------------------
      it { should respond_to :log_all_on }
      describe '#log_all_on' do
        before(:each) do
          @subj.should_log_command = @subj.should_log_output = false
        end
        it 'should apply only within block' do
          @subj.log_all_on do
            @subj.should_log_command.should be_true
            @subj.should_log_output.should be_true
          end
          @subj.should_log_command.should be_false
          @subj.should_log_output.should be_false
        end
        it 'should set permanently' do
          @subj.log_all_on
          @subj.should_log_command.should be_true
          @subj.should_log_output.should be_true
        end
      end

      #---------------------------------------------------------------------
      it { should respond_to :log_all_off }
      describe '#log_all_off' do
        it 'should apply only within block' do
          @subj.log_all_off do
            @subj.should_log_command.should be_false
            @subj.should_log_output.should be_false
          end
          @subj.should_log_command.should be_true
          @subj.should_log_output.should be_true
        end
        it 'should set permanently' do
          @subj.log_all_off
          @subj.should_log_command.should be_false
          @subj.should_log_output.should be_false
        end
      end

      #---------------------------------------------------------------------
      it { should respond_to :log_command_on }
      describe '#log_command_on' do
        before(:each) do @subj.should_log_command = false end
        it 'should apply only within block' do
          @subj.log_command_on do
            @subj.should_log_command.should be_true
          end
          @subj.should_log_command.should be_false
        end
        it 'should set permanently' do
          @subj.log_command_on
          @subj.should_log_command.should be_true
        end
      end

      #---------------------------------------------------------------------
      it { should respond_to :log_command_off }
      describe '#log_command_off' do
        it 'should apply only within block' do
          @subj.log_command_off do
            @subj.should_log_command.should be_false
          end
          @subj.should_log_command.should be_true
        end
        it 'should set permanently' do
          @subj.log_command_off
          @subj.should_log_command.should be_false
        end
      end

      #---------------------------------------------------------------------
      it { should respond_to :log_output_on }
      describe '#log_output_on' do
        before(:each) do @subj.should_log_output = false end
        it 'should apply only within block' do
          @subj.log_output_on do
            @subj.should_log_output.should be_true
          end
          @subj.should_log_output.should be_false
        end
        it 'should set permanently' do
          @subj.log_output_on
          @subj.should_log_output.should be_true
        end
      end

      #---------------------------------------------------------------------
      it { should respond_to :log_output_off }
      describe '#log_output_off' do
        it 'should apply only within block' do
          @subj.log_output_off do
            @subj.should_log_output.should be_false
          end
          @subj.should_log_output.should be_true
        end
        it 'should set permanently' do
          @subj.log_output_off
          @subj.should_log_output.should be_false
        end
      end

    end

  end
end end end
############################################################################
