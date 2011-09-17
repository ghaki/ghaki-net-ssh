require 'ghaki/net_ssh/telnet'
require 'ghaki/net_ssh/common_helper'

module Ghaki module NetSSH module Telnet_Testing
describe Telnet do
  include CommonHelper

  before(:each) do
    setup_common
  end

  ########################################################################
  context 'class' do

    subject { Telnet }

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
