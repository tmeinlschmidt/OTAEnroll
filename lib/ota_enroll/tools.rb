module OtaEnroll

  class Tools

    attr_reader :ssl_cert, :ssl_key
    attr_reader :root_cert, :root_key
    attr_reader :ra_cert, :ra_key
    attr_reader :sign_interm_cert, :server_interm_cert

    # return SSL certificates and keys
    def initialize
      @ssl_cert = OpenSSL::X509::Certificate.new(File.read(get_path(OtaEnroll.settings.ssl_crt))) if File.exists?(get_path(OtaEnroll.settings.ssl_crt))
      @ssl_key = OpenSSL::PKey::RSA.new(File.read(get_path(OtaEnroll.settings.ssl_key))) if File.exists?(get_path(OtaEnroll.settings.ssl_key))
      @root_cert = OpenSSL::X509::Certificate.new(File.read(get_path(OtaEnroll.settings.ca_crt))) if File.exists?(get_path(OtaEnroll.settings.ca_crt))
      @root_key = OpenSSL::PKey::RSA.new(File.read(get_path(OtaEnroll.settings.ca_key))) if File.exists?(get_path(OtaEnroll.settings.ca_key))
      @ra_cert = OpenSSL::X509::Certificate.new(File.read(get_path(OtaEnroll.settings.ra_crt))) if File.exists?(get_path(OtaEnroll.settings.ra_crt))
      @ra_key = OpenSSL::PKey::RSA.new(File.read(get_path(OtaEnroll.settings.ra_key))) if File.exists?(get_path(OtaEnroll.settings.ra_key))
      @sign_interm_cert = OpenSSL::X509::Certificate.new(File.read(get_path(OtaEnroll.settings.sign_interm_crt))) if File.exists?(get_path(OtaEnroll.settings.sign_interm_crt))
      @server_interm_cert = OpenSSL::X509::Certificate.new(File.read(get_path(OtaEnroll.settings.server_interm_crt))) if File.exists?(get_path(OtaEnroll.settings.server_interm_crt))
    end

    # returns local IP
    def self.local_ip
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily
      UDPSocket.open do |s|
        s.connect '64.233.187.99', 1
        s.addr.last
      end
      ensure
        Socket.do_not_reverse_lookup = orig
    end

    private

    # do not add rails.root if path begins with /
    def get_path(path)
      return '' if path.blank?
      return path if path[0] == '/'
      Rails.root.to_s + '/' + path
    end

  end

end
