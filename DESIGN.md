# 决策：以同名 `app-editors/emacs` ebuild 让 Neomacs 满足 Emacs 依赖

状态：**已裁决，待首个里程碑验收。** 尚未提交可安装 ebuild。

目标：让 overlay `neomacs-gentoo` 提供一个由 Neomacs 源码构建的
`app-editors/emacs` ebuild，使 `>=app-editors/emacs-${NEED_EMACS}:*` 依赖可解析，
并让 `/usr/bin/emacs` 通过 eselect 指向 Neomacs。Neomacs 项目目标是**完整替代
GNU Emacs**，本仓库的打包以此为目标，但每一步以实测为准，不超前宣称兼容。

## 被否决的方案

| 方案 | 结论 |
|---|---|
| `PROVIDE="app-editors/emacs"` | 不可行。旧式 PROVIDE virtual 已在 EAPI≥7 移除并被仓库禁止。与仓库无关，任何 ebuild 都不能用。 |
| `virtual/emacs` + 消费者改 `||` | 工作量更大且更脆弱。主树有 238 个非 elisp ebuild 与约 485 个 `app-emacs/*`（经 `elisp.eclass`）硬依赖 `app-editors/emacs` atom，逐包修补不现实。 |
| `package.provided` 本机豁免 | 不建立真实依赖边，depclean 有风险；是全局声明而非按消费者豁免。仅适合临时本机跳过，不是仓库方案。 |
| 保留 GNU Emacs 作构建器 + Neomacs 日常用 | 最省事，但不满足"不再因依赖拉 GNU Emacs"的目标。 |

## 核心认知：两套独立机制

让依赖**解析**与让 `/usr/bin/emacs` **实际运行** Neomacs 是两套独立机制：

- `elisp.eclass:73–74` 同时注入 `RDEPEND` 与 `BDEPEND`（`>=app-editors/emacs-${NEED_EMACS}:*`）。
- `elisp-common.eclass:204,210,304–309` 在消费者**构建期**固定调用未加版本的
  `/usr/bin/emacs`（`-batch -q --no-site-file`、`batch-byte-compile`）。

因此光满足 atom 不够：还必须提供一个**可工作**的 `emacs-<digit>*` 可执行文件，
经 eselect 接到 `/usr/bin/emacs`。否则会出假阳性——依赖由 GNU 满足、命令却跑
Neomacs（或反之），测试"通过"却没真正验证 Neomacs。

## 实测结论（本机核验）

- `eselect emacs` 用 glob `/usr/bin/emacs-[0-9]*` 发现目标
  （`/usr/share/eselect/modules/emacs.eselect:35–36`）→ `emacs-31-neomacs` 可发现，
  `emacs-neomacs` 不可。切换用完整目标名（`:117–126`）。
- `eselect` **拒绝**非 symlink 的 `/usr/bin/emacs`（`:241–242,274–275`）→
  ebuild 不得自带 `/usr/bin/emacs`，由 `eselect emacs update ifunset` 建立。
- `9999` **能**满足 `>=app-editors/emacs-31:*`（本机 `match_from_list` 实测；
  `portage/dep/__init__.py:3087–3103`）。但不推荐——它会满足一堆未验证的未来最低版本。
- `cargo_live_src_unpack` 要求 PV 含 `9999`（`cargo.eclass:600–604`）→
  固定版本快照必须用固定源码归档 + `cargo_src_unpack` + 离线 Cargo 输入。
- `IDEPEND` 自 **EAPI 8** 起（`portage/eapi.py:304`）。
- 版本矛盾：当前 checkout `57eebb9…` 的 `eval.rs` 写 `31.0.50`；已安装包
  `EGIT_VERSION=7c197e0…` 实测报告 `31.0.90`。**两套不同产物，不能互相作证。**

## 裁决的打包决策

- **SLOT=`31-neomacs`**：合法 SLOT，`:*` 接受任意 SLOT，可与 GNU `SLOT=31` 并存回退。
  不用 `SLOT=31`+宽 `!!` blocker（同 SLOT 本就替换关系，宽 blocker 与回退冲突）。
  SLOT 不自动隔离文件 → 用 Neomacs 专属 libexec/runtime 路径；内部仍叫
  `neomacs`/`neomacs.pdump`（`load.rs:2516–2534` 按可执行名找 dump）。
- **PV**：固定快照 `31.0.XX_pYYYYMMDD`。PV 取**该快照实际构建产物**报告的版本，
  禁止 sed 造假、别拿 grep eval.rs 当验收。固定 SHA + 离线 cargo 输入。
- **site 集成**：复用 `app-emacs/emacs-common`（装 `subdirs.el`、
  `/etc/emacs/site-start.el`、regen）。Neomacs **能**加载 site-gentoo——缺的是默认
  路径，不是能力：加 `EMACSLOADPATH` 后 `-batch -q` 实测自动加载 `site-gentoo` 并
  找到 ebuild-mode；`--no-site-file` 按预期不加载。`EMACSLOADPATH` 是已验证的
  最小桥接。有自己的 site fragment 时才 inherit `elisp-common`；**永不 inherit
  `elisp`**（会注入依赖 + 覆盖 phases）。
- **wrapper**：装 `/usr/bin/emacs-31-neomacs`（regular file，导出
  `NEOMACS_RUNTIME_ROOT`），不拥有 `/usr/bin/emacs`。切换：
  `eselect emacs set emacs-31-neomacs`。副作用：eselect 会先删再建 companion 链接，
  选 Neomacs 会移除 GNU 的 `/usr/bin/emacsclient` 链接。
- **IUSE**：只声明已验证的内置功能；`imagemagick` 等未实现的**不声明**（相关
  消费者解析失败 = 已知不支持，写 elog）。不因 Cargo 含库就虚报 ssl/gui/tree-sitter。

## 首个里程碑（go/no-go）：本机依赖闭包端到端试验

只验本机真实使用的 5 个包（`/etc/portage/sets/gentoo-package`）：
`ebuild-mode`、`ebuild-run-mode`、`emacs-ebuild-snippets`，外加 `tty-format`、
`yasnippet`。

验收用**同一源码快照**的 binary + pdump + runtime tree：

1. 按 eclass 参数完成版本探测与真实 `.el` 字节编译。
2. 加载新生成 `.elc`，验证 ebuild-mode/snippets 基本激活。
3. 验证正常 site 启动与 `--no-site-file` 行为。
4. 记录实际执行路径，禁止 GNU 回退掩盖结果。

当前阻塞：当前 checkout 二进制启动即 `exit 101 / pdump fingerprint mismatch`
（`main.rs:1995–2004`）——产物不配套。旧已装 Neomacs 加 `EMACSLOADPATH` 后 5 包
编译+激活成功（可行性证据，非最终验收）。

**通过前不提交任何可安装 ebuild 或仓库骨架。**

## 里程碑实验结果（已执行，通过）

`cargo xtask fresh-build --release --skip-build --bin-dir target/release
--runtime-root <repo>` 完整跑完后 binary/pdump 配套：

- **fingerprint mismatch 根因**：`neomacs` binary 内嵌
  `NEOMACS_PDUMP_FINGERPRINT_RECORD` 占位符
  `NEOMACS_PDUMP_FINGERPRINT_SLOT!!`，由 `xtask
  patch_primary_executable_fingerprint` 就地写成 sha256(normalized binary)；
  pdump 以 `<stem>-<binfp>.pdump` 命名。binary 变了而 pdump 未重建 →
  binary 期望的 fp ≠ pdump 里存的 fp。**非 Elisp 兼容性问题**，跑完整个
  fresh-build（patch → dump）即配套。当前 binary fp=`857054…`，对应
  `neomacs-857054….pdump` 生成成功。
- **emacs-version 实测 `31.0.50`**（非 31.0.90）→ PV 应为
  `31.0.50_pYYYYMMDD`，见「版本矛盾」。
- **5 包闭包（eclass 参数 `-batch -q --no-site-file -L . -f batch-byte-compile`）**：
  ebuild-mode / ebuild-run-mode / ebuild-snippets / tty-format / yasnippet
  的 9 个 `.el` 全部 byte-compile 成功（9 `.elc`）。`require` 5/5 成功，
  `ebuild-mode` `fboundp=t`。`--no-site-file` 正确抑制 site 加载。
- **go/no-go 通过**：可做 ebuild。

## 修正：EMACSLOADPATH 不生效（对当前快照）

oracle 称 `EMACSLOADPATH` 是已验证桥接——**对当前 checkout 失实**：load-path
仅硬编 `<runtime>/lisp` + `BOOTSTRAP_LOAD_PATH_SUBDIRS` 子目录
（`load.rs:4174,4529,985`），源码中**无 EMACSLOADPATH 读取**。该 claim 来自
旧安装版本，两套产物不能互证。

实测可行的桥接（当前快照）：

- `-L DIR` flag 生效（prepend/append load-path）。
- 顶层 `-L /usr/share/emacs/site-lisp` 后 `(load "site-gentoo.el")` 成功
  （`sg:t`）；site-gentoo 内每个 `50*-gentoo.el` fragment **自
  `add-to-list load-path`**，子目录自动接入，无需逐一 `-L`。
- 因此 wrapper 需 `-L <site-lisp 根>` + `-L 每个子目录`（复刻 GNU
  `subdirs.el` 展开，见下）+ **条件** `-l site-gentoo`（仅当无
  `-Q`/`--no-site-file`/`--no-site-lisp` 时）。
- 长期解在上游：实现 site-start.el / subdirs.el / EMACSLOADPATH 机制，
  取代 wrapper 桥接。属 upstream gap，记入 experiment 而非 ebuild 硬编码。

## ebuild 实测记录（emacs-31.0.50_p20260920）

- `unpack` 通过：3 distfile 校验解包；`GIT_CRATES` cosmic-text checkout 进
  WORKDIR；cargo config 生成 `[patch.'git-uri']` 指向本地 checkout。
- **cosmic-text 离线 bug**：它在 workspace `[patch.crates-io]` 里是
  `git = ...` 依赖；offline 下 git source 不能 fetch → src_prepare 把该行
  sed 改写为 `path = "${WORKDIR}/cosmic-text-<commit>"`（同 gentoo-zh/codex
  先例），并 grep 断言生效。
- `compile` 通过：`cargo_src_compile -p neomacs` + `cargo xtask fresh-build
  --skip-build`（patch fp → dump），1704 个 lisp 全量 byte-compile 成功。
- **wrapper argv 顺序教训**：`set --` 是 prepend。第一版用
  `--eval (load site-gentoo.el)` prepend 会落到所有 `-L` **之前**执行 →
  load-path 未建即 load → file-missing。修正：用 `-l site-gentoo`，构造
  argv 顺序 `-L根 -L子* -l site-gentoo <用户args>`（先 `-l` prepend，再循环
  prepend `-L子`，最后 prepend `-L根`），对应 GNU site-start 在 init 之前。
- wrapper 四组合实测（拷 image 到测试 prefix）：裸跑 `sg:t` + ebuild-mode
  激活；`--no-site-file` 下 `sg:nil` 但 site-lisp 子目录仍 `-L` 在
  load-path（GNU `subdirs.el` 语义：site init 跳过 ≠ 子目录消失），
  require ebuild-mode 成功；`--no-site-lisp` 干净；`--no-site-file`
  version probe `31.0.50`。与 eclass `elisp-compile`（`--no-site-file` +
  `-L .`）天然兼容。
- **非 root `ebuild` CLI 假象**：`newbin`/`dobin` 在非 root 下 `chown` 失败
  报 `dobin failed`，image 内容实际已生成正确；die 会中断后续 `doins` 使
  runtime tree 看似缺失。真 `emerge`（portage/root）无此限制，ebuild 无需改。

## 发布/维护流程

- `SRC_URI` 指向 `github.com/xz-dev/neomacs-gentoo/releases/download/${P}/
  ${P}-crates.tar.xz`。crates tarball 由
  `pycargoebuild -w --crate-tarball-path <path>` 在 `neomacs-bin/` member
  目录生成（约 60M/709 crates），需手动上传到该 release；本机 distdir 副本
  只够本地 merge。
- 每次 bump `NEOMACS_COMMIT`/PV：重新生成 crates tarball + 重算
  `cosmic-text` rev（若变）+ 重新 `ebuild ... manifest`。
- `ebuild ... manifest` 需要 3 个 distfile 在 `${DISTDIR}`：`${P}.gh.tar.gz`
  （neomacs archive）、`${P}-crates.tar.xz`、`cosmic-text-<commit>.gh.tar.gz`。

## 真 merge 实测（已完成）

`emerge =app-editors/emacs-31.0.50_p20260920::neomacs-gentoo` 完整装到系统：

- `/usr/bin/emacs-31-neomacs`（wrapper）+ `/usr/libexec/emacs/31.0.50_p20260920/
  {neomacs,neomacs.pdump}` + `/usr/share/emacs/31.0.50_p20260920/{etc,lisp}`。
- `eselect emacs list` 两目标并存：`emacs-31`（GNU，仍选中）、
  `emacs-31-neomacs`。`/usr/bin/emacs` 仍指 GNU（`update ifunset` 不抢）。
- 与 GNU `app-editors/emacs-31.1-r1:31` 同 slot 共存，vdb 双双注册。
- 意外彩蛋：merge 触发 **Doom Emacs init 重建**（`init.31.1.el`）——系统已
  把 neomacs 当 emacs-31 跑 doom sync，是 site 集成生效的旁证。
- 实机验证：wrapper 裸跑 `sg:t`+ebuild-mode 激活；`--no-site-file` 下
  `ebuild-mode.el` byte-compile 出 96KB `.elc` 且 require 成功。

切换/回退：`eselect emacs set emacs-31-neomacs` / `eselect emacs set emacs-31`。
