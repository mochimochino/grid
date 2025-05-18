# Hiroshima grid

広島サイトのファイルシステム構成についてまとめる。

環境準備-all node-
・EL9
ネットワーク設定
・



# Central Manager
items

# Woker Node
items

# Storage system
EOS Diopsideのインストール手順

## 必要なもの

### サーバー

- MGM (Management Node)：メタデータ管理、スケジューリング担当
    
    grid04,05,06
    
- FST (Filesystem/Storage Node)：データを格納するストレージサーバー
    
    nfs11,12,13
    
- QuarkDB / MQ　サーバー：メタデータベース(QuarkDB)とメッセージキュー(MQ)。MGMサーバー上で動作させる。

### OS

- AlmaLinux9を使用する。（公式では、CentOS 7/8)

### ネットワーク

- IPv4を全ノード間で接続
- DNSによるホスト名解決
    
    （DNS使用していない）
    
- NTP (Network Time Protocol)による時間同期。
    
    chronyを使用
    
- ファイアーウォール設定
    
    XRootD：TCP 1094(MGM), 1095(FST)など
    

### ストレージ

- FST用：データ格納用論理ボリューム
    
    RAID
    
- MGM用：SSDが望ましい

### ソフトウェアリポジトリ

==要確認==

- **EOS Diopside** およびその依存関係（XRootD など）を提供する YUM/DNF リポジトリへのアクセス。
- OS標準リポジトリ、EPELリポジトリなど。

### 依存ソフトウェア

- XRootD
- jemalloc(メモリ管理ライブラリ）
- FUSE（ファイルシステムマウント用）

## 手順

### システム設定

- NTP設定と時間同期を確認。
    
    chrony
    
- ホスト名、ネットワーク設定
- ファイアウォール設定
- SELinuxの設定

### リポジトリの設定

- 全ノードに、EOSや依存関係（XRootDなど）のリポジトリを追加設定

repo_eos_task.yml

- EPELリポジトリなども有効化する。

repo_epel_task.yml

- **ELRepo（Enterprise Linux Repository）リポジトリの有効化**に関する設定

**repo_elrepo_task.yml**

- EGI（European Grid Infrastructure）によるCA（Certificate Authority）のリポジトリを設定

**repo_egi_igtf_task.yml**

- WLCG用のリポジトリ（いらない気がする）

**repo_wlcg_task.yml**

### パッケージのインストール

- MGM：
    - eos-server
    - eos-mgm
    - eos-quarkdb
    - xrootd
    - eos-client
    - jemalloc
- FST：
    - eos-server
    - eos-fst
    - xrootd
    - eos-client
    - jemalloc

パッケージインストール用Playbook

システム基盤用

cronie,

crontabs,

cronie-anacron

rsync

cfg_firewall_task.yml：

Chrony

cfg_ssh_task.yml：

tune_sysctl_task.yml：

ストレージ用

mdraid_conf_task.yml：

smartctl_dump.py：

cfg_smartd_task.yml：

  

EOS用パッケージ

pkg_eos_mgm_task.yml ：

pkg_eos_fst_task.yml ：

XRootDの設定用

xrd.cf.fst,：

xrd.cf.mgm：

xrd.cf.mq：

QuarkDB用

quarkdb.pass：

xrd.cf.quarkdb0.j2：

監視用

Ganglia (gmond)**4...**: システム監視エージェント。

cfg_gmond_eos.yml：

Telegraf**9...**: InfluxDataの監視エージェント。

cfg_telegraf_task.yml：

Smartd**14...**: ディスクのSMART監視デーモン。

lmsensors**14...**: ハードウェアセンサー情報の取得ツール。

### FSTストレージ準備

- FSTノードに接続されたデータ用ディスクをフォーマット（例: mkfs.xfs)
- マウントポイント用にディレクトリを作成。
- /etc/fstabに追記し、永続的にマウントする。
- マウントポイントの所有者をEOSサービス実行ユーザーに設定。

### 設定ファイルの編集

- 全ノード：/etc/sysconfig/eosまたはeos_envで環境変数を設定。
    - EOS_INSTANCE_NAME
    - EOS_MGM_HOST
    - EOS_BROKER_URL
    - EOS_GEOTAG
- MGMノード
    - /etc/xrd.cf.mgm：XRootDの設定
    - QuarkDB/MQの設定ファイル
- FSTノード
    - /yec/xrd.cf.fst：XRootDの設定

### サービス起動と自動起動設定

- systemctl startとsystemctl enableを使用し、サービスの起動を有効化。
    - ただし、サービスの起動順序に注意が必要

### EOS初期設定

MGM上でeosコマンドを使用

- FSTノードをEOSクラスターに追加: `eos node add <fst_host>:<port> <config_cmd>`
- ストレージスペースを定義: `eos space define <space_name> ...`
- FST上のファイルシステムをスペースに追加: `eos fs add -s <space_name> <node_uuid> <path> ...`
- 状態を確認: `eos node ls`, `eos space ls`, `eos fs ls`

### セキュリティ設定

- 認証方式を設定

### 監視とBackup

- Gangliaで監視設定をする。
- MGMのメタデータの定期的なバクアップ手順を確立






# 以前のもの
# Hiroshima grid

広島サイトの構成についてまとめる。

**VOBOX
Notionから移行予定

**Woker Node
Notionから移行予定
Storage servers(EOS)




**EOS作成に必要な手順**

1. **環境準備:**
    - 対象ホスト（MGMサーバーとFSTサーバー）へのアクセス設定が必要です。Ansibleのインベントリファイル（例: `/inventory/`) でホストを定義します。
    - 必要なパッケージをインストールするために、yumまたはdnfが利用できる状態である必要があります.
    - EOSのリポジトリが設定されている必要があります (`repo_eos_task.yml`).
2. **MGM (メタデータマネージャー) サーバーのプロビジョニング:**
    - `/playbooks/000_provision_eosmgm.yml` を実行します。このプレイブックは以下の主要なタスクを実行します。
        - **共通設定:** `/etc/profile.d/` へのパス設定、タイムゾーン設定。
        - **EOS共通ファイルの同期:** `cfg_eos_setup_task.yml` をインクルードし、`quarkdb.pass`, `eos.keytab`, `xrd.cf.fst`, `xrd.cf.mgm`, `xrd.cf.mq` などの共通ファイルを `/etc/` ディレクトリにコピーします。また、`/var/eos` 以下の必要なディレクトリを作成し、適切なパーミッションを設定します。
        - **EOS環境設定:** `eos_env.j2` テンプレートから `/etc/sysconfig/eos_env` ファイルを作成します。このファイルには、MGMホスト名 (`EOS_MGM_HOST`), EOSインスタンス名 (`EOS_INSTANCE_NAME`), ブローカーURL (`EOS_BROKER_URL`), GeoTag (`EOS_GEOTAG`) などのEOSの基本設定が含まれます。
        - **QuarkDB設定:** `cfg_eosmgm_setup_task.yml` をインクルードし、QuarkDBに関連する設定を行います。具体的には、`/etc/systemd/system/xrootd@quarkdb0.service.d/` ディレクトリを作成し、`custom.conf` をコピー、`xrd.cf.quarkdb0.j2` テンプレートから `/etc/xrd.cf.quarkdb0` を作成します。また、`/var/log/quarkdb` などのQuarkDB用のディレクトリを作成します。
        - **パッケージインストール:** `pkg_eos_mgm_task.yml` をインクルードし、`eos-server`, `eos-client`, `jemalloc`, `eos-grpc`, `eos-quarkdb`, `alicetokenacc` などのMGMに必要なパッケージをインストールします。
        - **ストレージ設定:** `/playbooks/00server_storage.yml` および関連するタスク（例: `/playbooks/mdraid_cfg.yml`, `/playbooks/tasks/storage_*.yml`）を実行し、ディスクやRAID構成を行います。これには、`storcli` などのツールが含まれます。
        - **システム設定:** `tune_sysctl_task.yml` をインクルードし、`/etc/sysctl.d/` の設定ファイル を適用します。`root_tuning_list/tuning_generic.yml` に定義されたチューニングスクリプト（`/additions/root_tuning.d/` 配下）を実行します。これには、ネットワークMTUの設定 (`00-nm_mtu.tune_eth`), NICのリングサイズ設定 (`20-ring.tune_eth`), NICチャネル設定 (`25-channels.tune_eth`) などが含まれます。
        - **ファイアウォール設定:** `/playbooks/000_provision_eos_firewall.yml` を実行し、必要なファイアウォールルールを設定します。
        - **Ganglia設定 (オプション):** `cfg_gmond_eos.yml` を実行し、Gangliaモニタリングエージェント (gmond) を設定します。これには、`gmond.conf`, クラスター定義 (`02-cluster.conf.j2`), UDP送信設定 (`03-udp_send.conf.j2`) などが含まれます。
        - **IPSet設定 (オプション):** `ipset_task.yml` を実行し、IPSetによるファイアウォールルールを管理します。
    - **必要な主なファイル (MGM):**
        - `/playbooks/000_provision_eosmgm.yml`
        - `/playbooks/tasks/cfg_eos_setup_task.yml`
        - `/additions/eos_setup/eos_env.j2`
        - `/playbooks/tasks/cfg_eosmgm_setup_task.yml`
        - `/additions/eos_setup/xrd.cf.quarkdb0.j2`
        - `/playbooks/tasks/pkg_eos_mgm_task.yml`
        - `/playbooks/00server_storage.yml` (および関連するストレージ設定ファイル)
        - `/playbooks/tasks/tune_sysctl_task.yml`
        - `/additions/sysctl.d/*`
        - `/additions/root_tuning.d/*`
        - `/playbooks/tasks/pkg_eos_task.yml` (間接的にインクルードされる可能性あり)
        - `/playbooks/000_provision_eos_firewall.yml`
        - `/playbooks/tasks/cfg_gmond_eos.yml` (オプション)
        - `/additions/gmond_conf/*` (オプション)
        - `/playbooks/tasks/ipset_task.yml` (オプション)
3. **FST (ファイルサーバ) サーバーのプロビジョニング:**
    - `/playbooks/000_provision_eosfst.yml` を実行します。このプレイブックはMGMと同様の共通設定やストレージ設定に加えて、FSTに特化した設定を行います。
        - `_eos_env_roles` を "fst" に設定。
        - **パッケージインストール:** `pkg_eos_fst_task.yml` をインクルードし、`eos-server`, `eos-client`, `jemalloc` などのFSTに必要なパッケージをインストールします。
        - **EOS共通ファイルの同期:** MGMと同様に共通ファイルを同期しますが、`xrd.cf.fst` がFST用の設定ファイルとして利用されます。
        - **システム設定:** MGMと同様に、`tune_sysctl_task.yml` と `root_tuning_list/tuning_generic.yml` に基づくチューニングスクリプトを実行します。
        - **ファイアウォール設定:** `/playbooks/000_provision_eos_firewall.yml` を実行し、FSTに必要なファイアウォールルールを設定します。
    - **必要な主なファイル (FST):**
        - `/playbooks/000_provision_eosfst.yml`
        - `/playbooks/tasks/cfg_eos_setup_task.yml`
        - `/additions/eos_setup/eos_env.j2`
        - `/playbooks/tasks/pkg_eos_fst_task.yml`
        - `/playbooks/00server_storage.yml` (および関連するストレージ設定ファイル)
        - `/playbooks/tasks/tune_sysctl_task.yml`
        - `/additions/sysctl.d/*`
        - `/additions/root_tuning.d/*`
        - `/playbooks/tasks/pkg_eos_task.yml` (間接的にインクルードされる可能性あり)
        - `/playbooks/000_provision_eos_firewall.yml`
4. **EOSサービスの起動と設定:**
    - MGMとFSTのプロビジョニング後、それぞれのサーバーでEOSサービスを起動します。これには、systemdのサービス定義ファイル（例: `/etc/systemd/system/xrootd@.service`、`/additions/eos_setup/eos@.service.d/override.conf`）を利用します。
    - MGMとFST間の連携に必要な設定（例: 公開鍵の同期）は、`mgm2fst_sync` スクリプト などを用いて行います。
5. **クライアント設定:**
    - EOSにアクセスするクライアントマシンには、`eos-client` パッケージをインストールします。

これらの手順とファイルは、ソースコードから推測されるEOSシステム構築の基本的な流れです。実際の環境に合わせて、変数の設定や追加の構成管理が必要になる場合があります。特にストレージ構成 (`/playbooks/00server_storage.yml` および関連ファイル) は、環境に大きく依存するため、注意が必要です。



