# == Class: backuppc::params
#
# Params class for backuppc.
#
# === Authors
#
# Scott Barr <gsbarr@gmail.com>
#
class backuppc::params {
  case $::osfamily {
    'Debian': {
      $required_packages  = 'apache2-utils'
      $package            = 'backuppc'
      $service            = 'backuppc'
      $topdir             = '/var/lib/backuppc'
      $config_directory   = '/etc/backuppc'
      $config             = "${config_directory}/config.pl"
      $hosts              = "${config_directory}/hosts"
      $install_directory  = '/usr/share/backuppc'
      $cgi_directory      = "${install_directory}/cgi-bin"
      $cgi_image_dir      = "${install_directory}/image"
      $cgi_image_dir_url  = '/backuppc/image'
      $log_directory      = '/var/lib/backuppc/log'
      if ($::operatingsystemmajrelease == 6) {
        $config_apache      = '/etc/backuppc/apache.conf'
      } else {
        $config_apache      = '/etc/apache2/conf.d/backuppc.conf'
      }
      $group_apache       = 'www-data'
      $par_path           = '/usr/bin/par2\' if -x \'/usr/bin/par2'
      $gzip_path          = '/bin/gzip'
      $bzip2_path         = '/bin/bzip2'
      $tar_path           = '/bin/tar'
    }
    'RedHat': {
      $required_packages  = undef
      $package            = 'BackupPC'
      $service            = 'backuppc'
      $topdir             = '/var/lib/BackupPC'
      $config_directory   = '/etc/BackupPC'
      $config             = "${config_directory}/config.pl"
      $hosts              = "${config_directory}/hosts"
      $install_directory  = '/usr/share/BackupPC'
      $cgi_directory      = "${install_directory}/sbin"
      $cgi_image_dir      = "${install_directory}/html"
      $cgi_image_dir_url  = '/BackupPC/images'
      $log_directory      = '/var/log/BackupPC'
      $config_apache      = '/etc/httpd/conf.d/BackupPC.conf'
      $group_apache       = 'apache'
      $par_path           = ''
      $gzip_path          = '/usr/bin/gzip'
      $bzip2_path         = '/usr/bin/bzip2'
      $tar_path           = '/bin/gtar'
    }
    default: {
      fail("Operating system ${::operatingsystem}\
 is not supported by this module")
    }
  }
  $ssl_cert               = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  $ssl_key                = '/etc/ssl/private/ssl-cert-snakeoil.key'
  $ssl_chain              = undef
  $htpasswd_apache        = "${config_directory}/htpasswd"
  $collect                = true
  $tar_client_cmd         = "\$sshPath -q -x -n -l\
 root \$host env LC_ALL=C \$tarPath -c -v -f - -C \$shareName+ --totals"
  $tar_client_restore_cmd = "\$sshPath -q -x -l\
 root \$host env LC_ALL=C \$tarPath -x -p --numeric-owner --same-owner -v -f\
 - -C \$shareName+"
}
