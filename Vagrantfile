# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "guisso.local"

  config.vm.network :forwarded_port, guest: "80", host: "8083", host_ip: "127.0.0.1"
  config.vm.network :public_network, ip: '192.168.1.13'

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
  end

  config.vm.provision :shell do |s|
    s.privileged = false
    s.args = [ENV['REVISION'] || "1.2"]
    s.inline = <<-SH

    export DEBIAN_FRONTEND=noninteractive

    # Install required packages
    sudo apt-get update
    sudo -E apt-get -y install apache2 git \
      mysql-client libxml2-dev libxslt1-dev mysql-client libmysqlclient-dev nodejs \
      libcurl4-openssl-dev apache2-threaded-dev libapr1-dev libaprutil1-dev libyaml-dev postfix festival curl \
      build-essential pkg-config libncurses5-dev uuid-dev libjansson-dev

    # Install rvm
    gpg --keyserver hkp://pgp.mit.edu --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    curl -sSL https://get.rvm.io | bash -s stable
    source /home/vagrant/.rvm/scripts/rvm
    if sudo grep -q secure_path /etc/sudoers; then sudo sh -c "echo export rvmsudo_secure_path=1 >> /etc/profile.d/rvm_secure_path.sh" && echo Environment variable installed; fi

    # Setup rails application
    sudo mkdir -p /u/apps/guisso
    sudo chown `whoami` /u/apps/guisso
    git clone /vagrant /u/apps/guisso
    cd /u/apps/guisso
    if [ "$1" != '' ]; then
      git checkout $1;
      echo $1 > VERSION;
    fi

    # Install ruby and friends
    rvm install `cat .ruby-version`
    gem install bundler --no-rdoc --no-ri

    # Install passenger
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
    sudo apt-get install -y apt-transport-https ca-certificates
    sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
    sudo apt-get update
    sudo apt-get install -y libapache2-mod-passenger
    sudo a2enmod passenger

    # Create logs folder
    sudo mkdir -p /var/log/verboice
    sudo chown `whoami` /var/log/verboice

    # Configure apache website
    rvmsudo sh -c 'echo "<VirtualHost *:80>
  DocumentRoot /u/apps/guisso/public
  SetEnv RAILS_ENV production
  RailsEnv production
  PassengerSpawnMethod conservative
  PassengerLogFile /var/log/guisso/web.log
  `passenger-config about ruby-command | grep Apache | cut -d : -f2`
  <Directory /u/apps/guisso/public>
    Allow from all
    Options -MultiViews
    Require all granted
  </Directory>
</VirtualHost>" > /etc/apache2/sites-available/000-default.conf'

    # Configuration files
    echo "production:
  adapter: mysql2
  host: mysql.local
  database: guisso
  username: root
  password:
  pool: 5
  timeout: 5000
  reconnect: true
  encoding: utf8" > /u/apps/guisso/config/database.yml

    echo "
secret_token: 85f9324d1aad8d06d4302c243bbc0f2112207ceec9e7f4a0b425d7d0aaded75fd174e6f530c96ec7fbc0c12b09e975a504d436116cd27dbe048e7709a1d2ce0d
devise_secret_key: 8d056690b4d010f1a7002ff7b3f38b2b2a4712841cee8c6b4b4f7ded48f6b9d66acfee3f6a1627e60aad59cd1a6e0b2a1ee11f771e00a3a8a5d76bbf7b1fc752
devise_email: noreply@example.com
devise_confirmable: false
whitelisted_hosts:
  - .example.com
google:
  client_id:
  client_secret:" > /u/apps/guisso/config/settings.yml

    # Bundle
    bundle install --deployment --path .bundle --without "development test"
    gem install -v 0.4.6 io-console # Because reasons :-(
    bundle exec rake db:setup RAILS_ENV=production
    bundle exec rake assets:precompile RAILS_ENV=production

    # Restart apache
    sudo /etc/init.d/apache2 restart

  SH
  end
end
