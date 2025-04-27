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



