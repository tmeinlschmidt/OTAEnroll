module OtaEnroll

  class Tools

    attr_reader :ssl_cert, :ssl_key
    attr_reader :root_cert, :root_key
    attr_reader :ra_cert, :ra_key

    # return SSL certificates and keys
    def initialize
      @ssl_cert = OpenSSL::X509::Certificate.new(File.read(Rails.root.to_s + OtaEnroll.settings.ssl_crt)) if File.exists?(Rails.root.to_s + OtaEnroll.settings.ssl_crt)
      @ssl_key = OpenSSL::PKey::RSA.new(File.read(Rails.root.to_s + OtaEnroll.settings.ssl_key)) if File.exists?(Rails.root.to_s + OtaEnroll.settings.ssl_key)
      @root_cert = OpenSSL::X509::Certificate.new(File.read(Rails.root.to_s + OtaEnroll.settings.ca_crt)) if File.exists?(Rails.root.to_s + OtaEnroll.settings.ca_crt)
      @root_key = OpenSSL::PKey::RSA.new(File.read(Rails.root.to_s + OtaEnroll.settings.ca_key)) if File.exists?(Rails.root.to_s + OtaEnroll.settings.ca_key)
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

  end

end
