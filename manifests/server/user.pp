# == Define: backuppc::server::user
#
# Add user credentials to the backuppc htpasswd file.
#
# === Parameters
#
# [*ensure*]
# Present or absent
#
# [*username*]
# Namevar. Defaults to the title if no value is provided.
#
# [*password*]
# Password for the account. Will be converted to a sha encrypted password.
#
# === Authors
#
# Scott Barr <gsbarr@gmail.com>
#
define backuppc::server::user (
  $ensure   = 'present',
  $username = undef,
  $password = '',
) {
  include backuppc::params

  validate_re($ensure, '^(present|absent)$',
  'ensure parameter must have a value of: present or absent')

  $real_username = $username ? {
    undef   => $name,
    default => $username,
  }

  if empty($password) {
    fail("A password is required for the backuppc user account\
 named '${real_username}'")
  }

  $real_password = inline_template("{SHA}<%= Base64.encode64\
(Digest::SHA1.digest('${password}')).chomp! %>")

  Exec {
    require => Package[$backuppc::params::package],
    path    => ['/usr/bin', '/bin'],
  }

  $test        = "test -f ${backuppc::params::htpasswd_apache}"
  $test_pipe   = "|| OPT='-c';"
  $test_htpass = "htpasswd -bs \${OPT} ${backuppc::params::htpasswd_apache}\
 ${real_username} '${password}'"
  $unless      = "grep -q ${real_username}:${real_password}\
 ${backuppc::params::htpasswd_apache}"

  if $ensure == 'present' {
    exec {"${test} ${test_pipe} ${test_htpass}":
      unless  => $unless,
    }
  } else {
    exec {"htpasswd -D ${backuppc::params::htpasswd_apache} ${real_username}":
      onlyif  => "egrep -q '^${real_username}:'\
 ${backuppc::params::htpasswd_apache}",
    }
  }
}
