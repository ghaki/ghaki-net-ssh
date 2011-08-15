require 'ghaki/net_ssh/logger'

require 'mocha_helper'
require 'ghaki/net_ssh/common_helper'

module Ghaki module NetSSH module Logger_Testing
describe Logger do
  include CommonHelper

  before(:each) do
    setup_common
  end

  class UsingLogger
    include Logger
    attr_accessor :account
    def initialize opts={}
      setup_logger opts
      @account = opts[:account]
    end
  end

  context 'objects including' do

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

    describe '#log_command!' do
      it 'should log title, command, and host' do
        @logger.expects(:puts).with('SSH host : who').once
        @subj.log_command! 'SSH', 'who'
      end
      it 'should not log when supressed' do
        @subj.should_log_command = false
        @logger.expects(:puts).never
        @subj.log_command! 'SSH', 'who'
      end
    end

    describe '#log_exec!' do
      it 'should log title and output' do
        @logger.expects(:puts).with('SSH host : who').once
        @logger.expects(:puts).with('output').once
        @logger.expects(:liner).twice
        @subj.log_exec!('SSH', 'who') do 'output' end.should == 'output'
      end
      it 'should log only output when command is supressed' do
        @subj.should_log_command = false
        @logger.expects(:puts).with('SSH host : who').never
        @logger.expects(:puts).with('output').once
        @logger.expects(:liner).twice
        @subj.log_exec!('SSH', 'who') do 'output' end.should == 'output'
      end
      it 'should not log when both are supressed' do
        @subj.should_log_command = false
        @subj.should_log_output = false
        @logger.expects(:puts).never
        @logger.expects(:liner).never
        @subj.log_exec!('SSH', 'who') do 'output' end.should == 'output'
      end
      it 'should default for no output' do
        @subj.should_log_command = false
        @logger.expects(:puts).with('** NO OUTPUT **').once
        @logger.expects(:liner).never
        @subj.log_exec!('SSH', 'who') do nil end.should == ''
      end
    end

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
