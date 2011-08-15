require 'ghaki/net_ssh/shell'

module NetShellHelper

  def setup_netssh
    @tel_raw = stub_everything('Net::Telnet')
    ::Net::SSH::Telnet.stubs({
      :new => @tel_raw,
    })

    @ssh_raw = stub_everything('Net::SSH')
    ::Net::SSH.stubs({
      :start => @ssh_raw,
    })

    @ftp_raw = stub_everything('Net::SFTP')
    @ssh_raw.stubs({
      :sftp => @ftp_raw,
    })

    @ssh_obj = Ghaki::NetSSH::Shell.start({
      :logger => @logger,
      :hostname => 'host',
      :username => 'user',
      :password => 'secret',
    })

    @ftp_gak = stub_everything('Ghaki::NetSSH::FTP')
    Ghaki::NetSSH::FTP.stubs({
      :new => @ftp_gak,
    })
    @tel_gak = stub_everything('Ghaki::NetSSH::Telnet')
    Ghaki::NetSSH::Telnet.stubs({
      :new => @tel_gak,
    })

    @ssh_obj.stubs({
      :sftp   => @ftp_gak,
      :telnet => @tel_gak,
    })
  end

end
