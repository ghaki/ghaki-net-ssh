############################################################################
require 'ghaki/net_ssh/telnet'

require 'mocha_helper'
require 'ghaki/net_ssh/common_helper'

############################################################################
module Ghaki module NetSSH module TelnetTesting
  describe Telnet do

    before(:each) do
      setup_common
    end

    ########################################################################
    context 'class' do

      subject { Telnet }
      it { should respond_to :start }

      #---------------------------------------------------------------------
      describe '#start' do

        it 'should yield telnet' do
          @tel_raw.expects(:close).once
          @ssh_raw.expects(:close).once
          Telnet.start(@test_opts) do |tel|
            tel.should be_an_instance_of(Telnet)
          end
        end

        it 'should return telnet' do
          @tel_raw.expects(:close).once
          @ssh_raw.expects(:close).once
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

      it { should respond_to :exec! }
      context 'logging delegates' do
        [ :log_command_on,  :log_output_on,  :log_all_on,
          :log_command_off, :log_output_off, :log_all_off,
          :log_exec!, :log_command!,
        ].each do |token|
          it { should respond_to token }
        end
      end

      describe '#exec!' do
        it 'should delegate to telnet' do
          @tel_raw.expects(:cmd).with('who').returns('moo')
          @tel_gak.exec!('who').should == 'moo'
        end
      end

    end

  end
end end end
############################################################################
