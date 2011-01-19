############################################################################
require 'ghaki/logger/base'
require 'ghaki/net_ssh/logger'

############################################################################
module Ghaki module NetSSH module LoggerTesting
  describe Logger do

    class UsingLogger
      include Logger
      def initialize opts={}
        @logger = opts[:logger]
      end
    end

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

    before(:all) do
      make_log
    end

    context 'objects including' do
      subject { UsingLogger.new }
      %w{
        setup_logger
        log_all_on  log_command_on  log_output_on
        log_all_off log_command_off log_output_off
        log_exec! log_command!
      }.each do |name|
        it { should respond_to name.to_sym }
      end
    end

    context 'object methods' do
      describe '#setup_logger'    do pending end
      describe '#log_all_on'      do pending end
      describe '#log_all_off'     do pending end
      describe '#log_command_on'  do pending end
      describe '#log_command_off' do pending end
      describe '#log_output_on'   do pending end
      describe '#log_output_off'  do pending end
      describe '#log_exec!'       do pending end
      describe '#log_command!'    do pending end
    end

  end
end end end
############################################################################
