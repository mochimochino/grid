# Hiroshima grid

広島サイトのファイルシステム構成についてまとめる。EOSを用いたファイルシステムの構成と、設定ファイル、必要な環境を記載する。
（Gitlabへ移行）

## 環境準備-all node-
・EL9
ネットワーク設定
・
エイリアスが必要
### 必要なソフトウェア一覧
eos関連
CA関連
xroot-server(Playbookに追加する必要あり）
## MGM/QDB node
Alias: `eos.aligrid.hiroshima-u.ac.jp` ipv4 and ipv6(未完了）
- grid04
- grid05
- grid06
## FST node
- nfs11
- nfs12
- nfs13
## EOSのノードごとの役割と仕組み
## EOSの設定方法
#　その他
## モニタリングに便利なもの

# Central Manager
内部サーバー内のPDF参照

# Woker Node
内部サーバー内のPDF参照

# Storage system
EOS Diopsideのインストール手順

## 必要なもの
##リポジトリのディレクトリ構造
```
[root@grid04 grid]# tree
.
├── README.md
├── ansible_hu
│   ├── WN
│   │   ├── _condor_stderr
│   │   └── agent.startup.2936159
│   ├── additions
│   │   ├── broadcom_net
│   │   │   └── bnxtnvm
│   │   ├── broadcom_sas
│   │   │   ├── lsigetlinux.sh
│   │   │   ├── sas2ircu
│   │   │   ├── sas3flash
│   │   │   ├── sas3ircu
│   │   │   ├── storcli
│   │   │   └── storcliconf.ini
│   │   ├── chrony
│   │   │   ├── chrony.conf.client_generic
│   │   │   ├── chrony.conf.client_priv10
│   │   │   └── chrony.conf.client_priv172
│   │   ├── cron.d
│   │   │   └── tuning.cron
│   │   ├── eos_setup
│   │   │   ├── eos.keytab
│   │   │   ├── eos_env.example_ini
│   │   │   ├── eos_env.j2
│   │   │   ├── grid-security_xrootd
│   │   │   │   └── TkAuthz.Authorization
│   │   │   ├── quarkdb.pass
│   │   │   ├── xrd.cf.fst.j2
│   │   │   ├── xrd.cf.mgm.j2
│   │   │   ├── xrd.cf.quarkdb0.j2
│   │   │   └── xrootd@quarkdb0.service.d
│   │   │       └── custom.conf
│   │   ├── gmond_conf
│   │   │   ├── conf
│   │   │   │   ├── 03-udp_send.conf.j2
│   │   │   │   ├── conf.d
│   │   │   │   │   ├── 00-globals.conf
│   │   │   │   │   ├── 01-host.conf
│   │   │   │   │   └── 90-metrics.conf
│   │   │   │   └── gmond.conf
│   │   │   └── gmond.service.d
│   │   │       └── override.conf
│   │   ├── ipset
│   │   │   ├── ipset.j2
│   │   │   ├── ipset_eos.yml
│   │   │   └── ipset_sets_def
│   │   ├── ipset_blacklist
│   │   │   └── blacklist_alien_wn.yml
│   │   ├── iptables
│   │   │   ├── ip6tables.j2
│   │   │   └── iptables.j2
│   │   ├── root_bin
│   │   │   └── apply_tuning
│   │   ├── root_tuning.d
│   │   │   ├── 00-blockdev.tune
│   │   │   ├── 00-nm_mtu.tune_eth
│   │   │   ├── 01-mtu_txq.tune_eth
│   │   │   ├── 05-fq_shape.tune_eth
│   │   │   ├── 10-nic_lldp_off.tune_eth
│   │   │   ├── 20-ring.tune_eth
│   │   │   └── 25-channels.tune_eth
│   │   ├── root_tuning_list
│   │   │   └── tuning_generic.yml
│   │   ├── seatools
│   │   │   ├── get-seatools
│   │   │   ├── st
│   │   │   └── sthelp.txt
│   │   ├── smartctl
│   │   │   └── smartd.conf
│   │   ├── ssh
│   │   │   └── 00-hiroshimageneric.conf
│   │   ├── storage_cmds
│   │   │   ├── iostat_md
│   │   │   ├── list_storage
│   │   │   ├── md_check
│   │   │   ├── md_check_stop
│   │   │   ├── md_health
│   │   │   ├── md_mkformat
│   │   │   │   ├── create_md_array
│   │   │   │   ├── format_md_component
│   │   │   │   ├── format_mdraid
│   │   │   │   └── select_disk_range
│   │   │   ├── md_readd_dev
│   │   │   ├── md_rm_dev
│   │   │   ├── smart_temp_report
│   │   │   ├── smartctl_dump
│   │   │   ├── sysconfig_raid-check.j2
│   │   │   └── systemd_raid-check.j2
│   │   ├── sysctl.d
│   │   │   ├── 60-memory.conf
│   │   │   ├── 70-mtu.conf
│   │   │   ├── 72-packet_tuning.conf
│   │   │   ├── 80-network_buffers_10GB.conf
│   │   │   ├── 80-network_buffers_1GB.conf
│   │   │   ├── 80-network_buffers_25GB.conf
│   │   │   ├── 82-ipv4.conf
│   │   │   ├── 82-ipv6.conf
│   │   │   ├── 82-netcore.conf
│   │   │   ├── 84-fs.conf
│   │   │   ├── 84-kernel.conf
│   │   │   ├── 90-raid_speed.conf
│   │   │   ├── 90-singularity.conf
│   │   │   ├── 99-delayacct.conf
│   │   │   ├── 99-inotify.conf
│   │   │   └── 99-security.conf
│   │   ├── sysctl_lists
│   │   │   └── sysctl_generic.yml
│   │   └── tuned
│   │       └── hiroshima
│   │           └── tuned.conf
│   ├── ansible.cfg
│   ├── playbooks
│   │   ├── 000_provision_eosfst.yml
│   │   ├── 000_provision_eosmgm.yml
│   │   ├── 0717_config_dump.txt
│   │   ├── collect_eos_configs.yml
│   │   ├── collect_eos_fst_configs.yml
│   │   ├── configure_firewall.yml
│   │   ├── deploy_TkAuthz.yml
│   │   ├── deploy_eos_config_file.yml
│   │   ├── deploy_eos_config_file_fst.yml
│   │   ├── eos-remove-install.yml
│   │   ├── fetch_configs.yml
│   │   ├── group_vars
│   │   │   └── all.yml
│   │   ├── inventory_eos.yml
│   │   ├── inventory_wn.yml
│   │   ├── output.txt
│   │   ├── pip_install.yml
│   │   ├── pkg_mlsensor.yml
│   │   ├── systemctl_eos_all.yml
│   │   ├── systemctl_fst.yml
│   │   ├── systemctl_mgm.yml
│   │   ├── systemctl_mgm_qdb.yml
│   │   ├── tasks
│   │   │   ├── 00basic_tools.yml
│   │   │   ├── 00basic_tools_hw.yml
│   │   │   ├── 00storage_tools.yml
│   │   │   ├── back_cfg_eos_setup_task.yml
│   │   │   ├── back_cfg_eosmgm_setup_task.yml
│   │   │   ├── cfg_chrony_task.yml
│   │   │   ├── cfg_eos_setup_task.yml
│   │   │   ├── cfg_eosmgm_setup_task.yml
│   │   │   ├── cfg_firewall_task.yml
│   │   │   ├── cfg_gmond_eos.yml
│   │   │   ├── cfg_gmond_template.yml
│   │   │   ├── cfg_lldpd_task.yml
│   │   │   ├── cfg_lmsensors.yml
│   │   │   ├── cfg_smartd_task.yml
│   │   │   ├── cfg_ssh_task.yml
│   │   │   ├── cfg_tuned_task.yml
│   │   │   ├── mdraid_conf_task.yml
│   │   │   ├── pkg_chrony_task.yml
│   │   │   ├── pkg_cvmfs_task.yml
│   │   │   ├── pkg_eos_fst_task.yml
│   │   │   ├── pkg_eos_mgm_task.yml
│   │   │   ├── pkg_gmond_task.yml
│   │   │   ├── pkg_igtfca_task.yml
│   │   │   ├── pkg_kernelml_install_task.yml
│   │   │   ├── pkg_lldpd_task.yml
│   │   │   ├── pkg_lsc_vomses_task.yml
│   │   │   ├── pkg_mlsensor_task.yml
│   │   │   ├── pkg_smartd_task.yml
│   │   │   ├── pkg_tuned_task.yml
│   │   │   ├── pkg_utils_task.yml
│   │   │   ├── pkg_yum-utils_task.yml
│   │   │   ├── repo_egi_igtf_task.yml
│   │   │   ├── repo_elrepo_task.yml
│   │   │   ├── repo_eos_task.yml
│   │   │   ├── repo_epel_task.yml
│   │   │   ├── repo_wlcg_task.yml
│   │   │   ├── seatools_sync.yml
│   │   │   ├── storage_cli.yml
│   │   │   ├── tune_scripts_task.yml
│   │   │   └── tune_sysctl_task.yml
│   │   └── test_connect_port_eos.yml
│   └── to_check
│       ├── eos_config_dump.txt
│       ├── eos_configs
│       │   ├── grid04
│       │   │   └── etc
│       │   │       ├── eos
│       │   │       │   └── config
│       │   │       │       └── generic
│       │   │       │           └── all
│       │   │       ├── sysconfig
│       │   │       │   └── eos_env
│       │   │       ├── xrd.cf.mgm
│       │   │       ├── xrd.cf.quarkdb
│       │   │       └── xrd.cf.quarkdb0
│       │   ├── grid05
│       │   │   └── etc
│       │   │       ├── eos
│       │   │       │   └── config
│       │   │       │       └── generic
│       │   │       │           └── all
│       │   │       ├── sysconfig
│       │   │       │   └── eos_env
│       │   │       ├── xrd.cf.mgm
│       │   │       ├── xrd.cf.quarkdb
│       │   │       └── xrd.cf.quarkdb0
│       │   ├── grid06
│       │   │   └── etc
│       │   │       ├── eos
│       │   │       │   └── config
│       │   │       │       └── generic
│       │   │       │           └── all
│       │   │       ├── sysconfig
│       │   │       │   └── eos_env
│       │   │       ├── xrd.cf.mgm
│       │   │       ├── xrd.cf.quarkdb
│       │   │       └── xrd.cf.quarkdb0
│       │   ├── nfs11
│       │   │   └── etc
│       │   │       ├── eos
│       │   │       │   └── config
│       │   │       │       └── generic
│       │   │       │           └── all
│       │   │       ├── sysconfig
│       │   │       │   └── eos_env
│       │   │       ├── xrd.cf.fst
│       │   │       └── xrd.cf.quarkdb
│       │   ├── nfs12
│       │   │   └── etc
│       │   │       ├── eos
│       │   │       │   └── config
│       │   │       │       └── generic
│       │   │       │           └── all
│       │   │       ├── sysconfig
│       │   │       │   └── eos_env
│       │   │       ├── xrd.cf.fst
│       │   │       └── xrd.cf.quarkdb
│       │   └── nfs13
│       │       └── etc
│       │           ├── eos
│       │           │   └── config
│       │           │       └── generic
│       │           │           └── all
│       │           ├── sysconfig
│       │           │   └── eos_env
│       │           ├── xrd.cf.fst
│       │           └── xrd.cf.quarkdb
│       └── grid_security
│           └── TkAuthz.Authorization
└── eos_0427.drawio.pdf

71 directories, 175 files
```







