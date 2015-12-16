#
# Cookbook Name:: pg_bouncer
# Spec:: configure
#
# The MIT License (MIT)
#
# Copyright (c) 2015 Jeffrey Hulten
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'spec_helper'

describe 'pg_bouncer::configure' do
  let(:runner) do
    ChefSpec::ServerRunner.new do |node|
      node.automatic['ipaddress'] = '10.1.2.3'
      node.set['pg_bouncer']['instances']['test_instance'] = instance
    end
  end

  let(:ini_file) { '/etc/pgbouncer/pgbouncer-test_instance.ini' }
  let(:user_file) { '/etc/pgbouncer/userlist-test_instance.txt' }
  let(:logrotate_file) {'/etc/logrotate.d/pgbouncer-test_instance'}
  let(:init_file) { '/etc/init/pgbouncer-test_instance.conf' }

  subject { runner.converge(described_recipe) }

  context 'With a single instance, taking all defaults' do
    let(:instance) do
      {
        databases: {
          'dbname' => {
            alias: 'dbalias',
            port: 1234
          }
        }, 
        userlist: { 'username' => 'pa55w0rd' }
      }
    end

    it { is_expected.to create_template(ini_file) }
    it { is_expected.to render_file(ini_file).with_content(/^dbalias = port=1234 dbname=dbname *$/) }
    
    it { is_expected.to create_template(user_file) }
    it { is_expected.to render_file(user_file).with_content(/^"username" "pa55w0rd"$/) }

    it { is_expected.to create_template(logrotate_file) }
    it { is_expected.to render_file(logrotate_file).with_content(/^\/var\/log\/pgbouncer\/pgbouncer-test_instance.log/) }
    
    it { is_expected.to create_template(init_file) }
    it { is_expected.to render_file(init_file).with_content(/^env USER=pgbouncer$/) }
    it { is_expected.to render_file(init_file).with_content(/^env RUNDIR=\/var\/run\/pgbouncer$/) }
    it { is_expected.to render_file(init_file).with_content(/^env DAEMON_OPTS="-d -R \/etc\/pgbouncer\/pgbouncer-test_instance.ini"$/) }
    it { is_expected.to render_file(init_file).with_content(/^limit nofile 65000 65000$/) }

    
  end
  context 'With a single instance, overriding all settings' do
    let(:instance) do
      {
        databases: {
          'dbname' => {
            host: '3.4.5.6',
            alias: 'dbalias',
            port: 1234
          }
        }, 
        userlist: { 'username' => 'pa55w0rd' },
        auth_type: 'md4',
        listen_addr: '9.9.9.9',
        listen_port: '4400',
        log_dir: '/mnt/log/pgbouncer',
        socket_dir: '/run/pgbouncer/db_sockets',
        pid_dir: '/run/pgbouncer',
        admin_users: ['pgbouncer_god'],
        stats_users: ['pgbouncer_snitch'],
        pool_mode: 'session',
        server_reset_query: 'DISCARD ALL; DROP TABLE Students;',
        max_client_conn: 99,
        default_pool_size: 33,
        min_pool_size: 11,
        reserve_pool_size: 22,
        server_idle_timeout: 3666,
        server_round_robin: 0,
        connect_query: 'CREATE TABLE Students;',
        tcp_keepalive: 1,
        tcp_keepidle: 3,
        tcp_keepintvl: 3,
        soft_limit: 64_001,
        hard_limit: 64_001,
        rotate_logs: false,
        service_state: [:disable, :restart],
        additional: {'additional_key' => 'additional_value'}        
      }
    end

    it { is_expected.to create_template(user_file) }
    it { is_expected.to render_file(user_file).with_content(/^"username" "pa55w0rd"$/) }
    it { is_expected.to create_template(ini_file) }
    [
      /^logfile = \/mnt\/log\/pgbouncer\/pgbouncer-test_instance.log$/,
      /^pidfile = \/run\/pgbouncer\/pgbouncer-test_instance.pid$/,
      /^listen_addr = 9.9.9.9$/,
      /^listen_port = 4400$/,
      /^unix_socket_dir = \/run\/pgbouncer\/db_sockets\/$/,
      /^auth_type = md4$/,
      /^auth_file = \/etc\/pgbouncer\/userlist-test_instance.txt$/,
      /^dbalias = host='3.4.5.6' port=1234 dbname=dbname connect_query='CREATE TABLE Students;'$/,
      /^admin_users = pgbouncer_god$/,
      /^stats_users = pgbouncer_snitch$/,
      /^pool_mode = session$/,
      /^server_reset_query = DISCARD ALL; DROP TABLE Students;$/,
      /^max_client_conn = 99$/,
      /^default_pool_size = 33$/,
      /^min_pool_size = 11$/,
      /^reserve_pool_size = 22$/,
      /^server_round_robin = 0$/,
      /^server_idle_timeout = 3666$/,
      /^tcp_keepalive = 1$/,
      /^tcp_keepidle = 3$/,
      /^tcp_keepintvl = 3$/,
      /^additional_key = additional_value$/
    ].each do |regex|
      it { is_expected.to render_file(ini_file).with_content(regex) }
    end
  end
end