# Hiroshima grid

広島サイトの構成についてまとめる。

VOBOX


Woker Node

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


## Getting started

To make it easy for you to get started with GitLab, here's a list of recommended next steps.

Already a pro? Just edit this README.md and make it your own. Want to make it easy? [Use the template at the bottom](#editing-this-readme)!

## Add your files

- [ ] [Create](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#create-a-file) or [upload](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#upload-a-file) files
- [ ] [Add files using the command line](https://docs.gitlab.com/ee/gitlab-basics/add-file.html#add-a-file-using-the-command-line) or push an existing Git repository with the following command:

```
cd existing_repo
git remote add origin https://gitlab.cern.ch/tamatsum/hiroshima-grid.git
git branch -M master
git push -uf origin master
```

## Integrate with your tools

- [ ] [Set up project integrations](https://gitlab.cern.ch/tamatsum/hiroshima-grid/-/settings/integrations)

## Collaborate with your team

- [ ] [Invite team members and collaborators](https://docs.gitlab.com/ee/user/project/members/)
- [ ] [Create a new merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html)
- [ ] [Automatically close issues from merge requests](https://docs.gitlab.com/ee/user/project/issues/managing_issues.html#closing-issues-automatically)
- [ ] [Enable merge request approvals](https://docs.gitlab.com/ee/user/project/merge_requests/approvals/)
- [ ] [Set auto-merge](https://docs.gitlab.com/ee/user/project/merge_requests/merge_when_pipeline_succeeds.html)

## Test and Deploy

Use the built-in continuous integration in GitLab.

- [ ] [Get started with GitLab CI/CD](https://docs.gitlab.com/ee/ci/quick_start/index.html)
- [ ] [Analyze your code for known vulnerabilities with Static Application Security Testing (SAST)](https://docs.gitlab.com/ee/user/application_security/sast/)
- [ ] [Deploy to Kubernetes, Amazon EC2, or Amazon ECS using Auto Deploy](https://docs.gitlab.com/ee/topics/autodevops/requirements.html)
- [ ] [Use pull-based deployments for improved Kubernetes management](https://docs.gitlab.com/ee/user/clusters/agent/)
- [ ] [Set up protected environments](https://docs.gitlab.com/ee/ci/environments/protected_environments.html)

***

# Editing this README

When you're ready to make this README your own, just edit this file and use the handy template below (or feel free to structure it however you want - this is just a starting point!). Thanks to [makeareadme.com](https://www.makeareadme.com/) for this template.

## Suggestions for a good README

Every project is different, so consider which of these sections apply to yours. The sections used in the template are suggestions for most open source projects. Also keep in mind that while a README can be too long and detailed, too long is better than too short. If you think your README is too long, consider utilizing another form of documentation rather than cutting out information.

## Name
Choose a self-explaining name for your project.

## Description
Let people know what your project can do specifically. Provide context and add a link to any reference visitors might be unfamiliar with. A list of Features or a Background subsection can also be added here. If there are alternatives to your project, this is a good place to list differentiating factors.

## Badges
On some READMEs, you may see small images that convey metadata, such as whether or not all the tests are passing for the project. You can use Shields to add some to your README. Many services also have instructions for adding a badge.

## Visuals
Depending on what you are making, it can be a good idea to include screenshots or even a video (you'll frequently see GIFs rather than actual videos). Tools like ttygif can help, but check out Asciinema for a more sophisticated method.

## Installation
Within a particular ecosystem, there may be a common way of installing things, such as using Yarn, NuGet, or Homebrew. However, consider the possibility that whoever is reading your README is a novice and would like more guidance. Listing specific steps helps remove ambiguity and gets people to using your project as quickly as possible. If it only runs in a specific context like a particular programming language version or operating system or has dependencies that have to be installed manually, also add a Requirements subsection.

## Usage
Use examples liberally, and show the expected output if you can. It's helpful to have inline the smallest example of usage that you can demonstrate, while providing links to more sophisticated examples if they are too long to reasonably include in the README.

## Support
Tell people where they can go to for help. It can be any combination of an issue tracker, a chat room, an email address, etc.

## Roadmap
If you have ideas for releases in the future, it is a good idea to list them in the README.

## Contributing
State if you are open to contributions and what your requirements are for accepting them.

For people who want to make changes to your project, it's helpful to have some documentation on how to get started. Perhaps there is a script that they should run or some environment variables that they need to set. Make these steps explicit. These instructions could also be useful to your future self.

You can also document commands to lint the code or run tests. These steps help to ensure high code quality and reduce the likelihood that the changes inadvertently break something. Having instructions for running tests is especially helpful if it requires external setup, such as starting a Selenium server for testing in a browser.

## Authors and acknowledgment
Show your appreciation to those who have contributed to the project.

## License
For open source projects, say how it is licensed.

## Project status
If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.
