# handle certificates
namespace :cert do

  desc 'Generate CA certificates'
  task :ca => :environment do
    @root_key = OpenSSL::PKey::RSA.new(1024)
    @root_cert = OtaEnroll::Cert.issue_cert( OpenSSL::X509::Name.parse(
      "/O=None/CN=#{OtaEnroll.settings.organization} CA"),
      @root_key, 1, Time.now, Time.now+(86400*365),
      [
        ["basicConstraints","CA:TRUE",true],
        ["keyUsage","Digital Signature,keyCertSign,cRLSign",true]
      ],
      nil, nil, OpenSSL::Digest::SHA1.new)

    @serial = 100

    File.open("#{get_path}/ca_private.pem", "w") { |f| f.write @root_key.to_pem }
    File.open("#{get_path}/ca_cert.pem", "w") { |f| f.write @root_cert.to_pem }
    File.open("#{get_path}/serial", "w") { |f| f.write @serial.to_s }
  end

  desc 'generate RA certificates'
  task :ra => :environment do
    keys = OtaEnroll::Tools.new
    @serial = 1
    @ra_key = OpenSSL::PKey::RSA.new(1024)
    @ra_cert = OtaEnroll::Cert.issue_cert( OpenSSL::X509::Name.parse(
      "/O=None/CN=#{OtaEnroll.settings.organization} SCEP RA"),
      @ra_key, @serial, Time.now, Time.now+(86400*365),
      [
        ["basicConstraints","CA:TRUE",true],
        ["keyUsage","Digital Signature,keyEncipherment",true]
      ],
      keys.root_cert, keys.root_key, OpenSSL::Digest::SHA1.new)
    @serial += 1
    File.open("#{get_path}/ra_private.pem", "w") { |f| f.write @ra_key.to_pem }
    File.open("#{get_path}/ra_cert.pem", "w") { |f| f.write @ra_cert.to_pem }
  end

  desc 'generate SSL keys'
  task :ssl => :environment do
    keys = OtaEnroll::Tools.new
    @serial = 1
    @address = "enroll.appbounty.net"
    STDERR.puts "address is #{@address}"
    @ssl_key = OpenSSL::PKey::RSA.new(1024)
    @ssl_cert = OtaEnroll::Cert.issue_cert( OpenSSL::X509::Name.parse("/O=None/CN=enroll.appbounty.net"),
      @ssl_key, @serial, Time.now, Time.now+(86400*365),
      [
        ["keyUsage","Digital Signature",true] ,
        ["subjectAltName", "DNS:" + @address, true]
      ],
      keys.root_cert, keys.root_key, OpenSSL::Digest::SHA1.new)
      @serial += 1
    File.open("#{get_path}/serial", "w") { |f| f.write @serial.to_s }
    File.open("#{get_path}/ssl_private.pem", "w") { |f| f.write @ssl_key.to_pem }
    File.open("#{get_path}/ssl_cert.pem", "w") { |f| f.write @ssl_cert.to_pem }
  end

  private

  def load_keys
    @root_key = OpenSSL::PKey::RSA.new(File.read("#{get_path}/ca_private.pem"))
    @root_cert = OpenSSL::X509::Certificate.new(File.read("#{get_path}/ca_cert.pem"))
    @serial = File.read("#{get_path}/serial").to_i
  end

  def get_path
    Rails.root.to_s+"/support"
  end

end
# desc "Explaining what the task does"
# task :ota_enroll do
#   # Task goes here
# end
