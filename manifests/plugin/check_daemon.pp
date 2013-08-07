class monitoring::plugin::check_daemon {

  include monitoring::params
  $nagios_extra_plugins = $monitoring::params::nagios_extra_plugins
  $ensure = $monitoring::params::ensure

  file { "scripts_check_daemon":
    ensure  => $ensure,
    name  => "${nagios_extra_plugins}/check_daemon",
    mode  => 755,
    owner  => root,
    group  => root,
    content  => template("monitoring/scripts/check_daemon.pl.erb"),
    require  => File[$nagios_extra_plugins],
  }
  package { "perl-Proc-ProcessTable":
    ensure => installed,
    name => $osfamily ? { RedHat => "perl-Proc-ProcessTable", Debian => "libproc-processtable-perl" },
  }
  package { "lsof":
    ensure => installed,
  }
  package { "perl-IPC-Run3":
    ensure => installed,
  }
  package { "perl-Pod-Usage":
    ensure => installed,
  }

  exec { "install Unix::Lsof via cpan":
    command => "perl -MCPAN -e '\$ENV{PERL_MM_USE_DEFAULT}=1; CPAN::Shell->install(\"Unix::Lsof\")'",
    onlyif => "test `perl -MUnix::Lsof -e 'print 1' 2>/dev/null || echo 0` == '0'",
    require => [Package["lsof"],Package["perl-IPC-Run3"]],
  }

}
