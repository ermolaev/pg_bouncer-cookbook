default['pg_bouncer']['upgrade'] = true

instance_defaults = {
  databases: [],
  userlist: {},
  auth_type: 'md5',
  listen_addr: "#{node['ipaddress']}",
  listen_port: '6432',
  user: 'pgbouncer',
  group: 'pgbouncer',
  log_dir: '/var/log/pgbouncer',
  socket_dir: '/etc/pgbouncer/db_sockets',
  pid_dir: '/var/run/pgbouncer',
  admin_users: ['pgbouncer_admin'],
  stats_users: ['pgbouncer_monitor'],
  pool_mode: 'transaction',
  server_reset_query: 'DISCARD ALL;',
  max_client_conn: 60,
  default_pool_size: 30,
  min_pool_size: 10,
  reserve_pool_size: 5,
  server_idle_timeout: 3600,
  server_round_robin: 1,
  connect_query: '',
  tcp_keepalive: 1,
  tcp_keepidle: 0,
  tcp_keepintvl: 0,
  soft_limit: 65_000,
  hard_limit: 65_000,
  rotate_logs: true,
  additional: {}
}

default['pg_bouncer']['instance_defaults'] = instance_defaults
default['pg_bouncer']['instances'] = {}