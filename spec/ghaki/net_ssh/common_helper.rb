require 'ghaki/account/base'

def setup_common

  @logger = stub_everything('Ghaki::Logger::Base')
  @logger.stubs(:level).returns(2)

  @user_opts = {
    :username => 'user',
    :hostname => 'host',
    :password => 'secret',
  }
  @account = Ghaki::Account::Base.new @user_opts
  @test_opts = {
    :account  => @account,
    :logger   => @logger,
  }

  @ssh_raw = mock('Net::SSH')
  @tel_raw = mock('Net::Telnet')
  @ftp_raw = mock('Net::SFTP')
  @ssh_raw.stubs( :sftp => @ftp_raw )

  ::Net::SSH.stubs( :start => @ssh_raw )
  ::Net::SSH::Telnet.stubs( :new => @tel_raw )

end
