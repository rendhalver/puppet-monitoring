
class monitoring::host {
  include monitoring::params
  $ensure = $monitoring::params::ensure
  $sms_alerts = $monitoring::params::sms_alerts
  $notifications = $monitoring::params::notifications
  $monitoring_server = $monitoring::params::monitoring_server
  $monitoring_service = $monitoring::params::monitoring_service
  $host_name = $monitoring::params::host_name
  $host_ip = $monitoring::params::host_ip
  $hostgroup = $::hostgroup
  $host_groups = $monitoring::params::host_groups
  $parents = $monitoring::params::parents
  $host_type = $monitoring::params::host_type
  $host_alias = $monitoring::params::host_alias
  $check_period = $monitoring::params::check_period
  $notification_period = $monitoring::params::notification_period
  if is_array($host_groups) {
    if empty($hostgroup) {
      $host_groups_full = join($host_groups,",")
    } else {
      $host_groups_full = join(concat(any2array($hostgroup),$host_groups),",")
    }
  } else {
    if empty($hostgroup) {
      $host_groups_full = "${host_groups}"
    } else {
      $host_groups_full = "${hostgroup},${host_groups}"
    }
  }

  @@nagios_host { $host_name:
    ensure              => $ensure,
    use                 => $host_type,
    alias               => $host_alias,
    address             => $host_ip,
    hostgroups          => $host_groups_full,
    parents             => $parents,
    contact_groups      => $sms_alerts ? { false => "admins,linux_admins", true => "admins,linux_admins,linux_admin_sms" },
    notification_period => $notification_period,
    check_period        => $check_period,
    notify              => Class[$monitoring_service],
    #require             => Nagios_hostgroup[$hostgroup],
    tag                 => $monitoring_server,
  }

  include monitoring::service::ping
  include monitoring::service::users
  include monitoring::service::total_procs
  include monitoring::service::disk
  include monitoring::service::memory
  include monitoring::service::load
  include monitoring::service::swap
  include monitoring::service::updates
  include monitoring::service::reboot

}
