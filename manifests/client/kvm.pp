# == Class: backuppc::client::kvm
#
# Configures backups for KVM
# Note, calls the '--clean' before running the backup script which
# delates all files in the backups directory.
#
# === Parameters
#
# @parma [String] backup_directory
#   The directory that the vm images will be backed up to.
#   Default: /var/lib/libvirt/images/virt-backup
#
# @param [Boolean] concurrent_mode
#   There are two modes to run kvm backups.
#
#   The standard mode is where all vms are shutdown at the same time,
#   images are dumped, and then all vms are started again.  This mode requires
#   the least amount of time.
#
#   Concurrent mode is where vms are shutdown sequentially, images dumped,
#   and then started again.  This means that during the backup process
#   there is minimum impact to the uptime of running vms.  Although this mode
#   takes longer to perform.
#
# @param [String] schedule_minute
#   The cron job minute to run.
#
# @param [String] schedule_hour
#   Uses the cron resource to schedule the running
#   @see https://docs.puppetlabs.com/references/latest/type.html#cron
#
# @param [String] schedule_weekday
#   Uses cron.  This is the weekend parameter.
#
# @param [Optional[String]] exclude_vms
#   A string contains the names of the vms separated by a '|' to be excluded.
#
class backuppc::client::kvm (
  String           $backup_directory = '/var/lib/libvirt/images/virt-backup',
  Boolean          $concurrent_mode  = false,
  String           $schedule_minute  = '5',
  String           $schedule_hour    = '3',
  String           $schedule_weekday = '6',
  Optional[String] $exclude_vms      = undef,
  ) {
  anchor {'backuppc::client::kvm::begin': }

  # === variables === #
  $command = '/usr/local/bin/kvm-clone-dump.bash'
  $clean   = "${command} --clean"

  # build command arguments
  if $concurrent_mode {
    $arg1 = '-o'
  }else{
    $arg1 = '-d'
  }

  if $exclude_vms {
    $arg2 = "-e=${exclude_vms}"
  }else{
    $args2 = ''
  }

  $command_args = "${arg1} -d=${backup_directory} ${arg2}"

  # download the backup script.
  file {$command:
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/backuppc/kvm-clone-dump.bash',
    require => Anchor['backuppc::client::kvm::begin'],
  }

  # make sure the directory exists
  file {$backup_directory:
    ensure  => directory,
    require => File[$command],
  }

  # set a cron job for running the backup scripts
  # currenty set to
  cron {'kvm_backups':
    command => "${clean} && ${command} ${command_args}",
    minute  => $schedule_minute,
    hour    => $schedule_hour,
    weekday => $schedule_weekday,
    require => File[$backup_directory],
  }

  anchor {'backuppc::client::kvm::end':
    require => Cron['kvm_backups'],
  }
}