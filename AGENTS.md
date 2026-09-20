# AGENTS.md — neomacs-gentoo maintainer runbook

Maintainer-facing commands and invariants for this overlay. **Read `DESIGN.md`
first** — it is the single source of truth for *why* the ebuild is shaped this
way (dependency model, eselect/site-lisp mechanics, experiment evidence). This
file is only the *how*.

## The one invariant

`/usr/bin/emacs` must run Neomacs when the user selects it, AND Portage must
resolve `>=app-editors/emacs-${NEED_EMACS}:*` to this package. Two separate
mechanisms; a change that satisfies the atom but breaks the runtime binary (or
vice versa) is a regression. Never ship `/usr/bin/emacs` as a real file —
eselect owns it.

## Don't regress

- Keep `cargo xtask fresh-build --skip-build` in `src_compile` — it patches the
  pdump fingerprint into the binary then dumps the matching image. Replacing it
  with plain `cargo build` reproduces the `pdump fingerprint mismatch` startup
  crash (exit 101).
- `src_prepare` must keep the cosmic-text `git`→`path` rewrite — the only git
  dep; offline builds can't fetch it otherwise.
- Wrapper `set --` is prepend-only. argv must end as `-L<subdirs> -l
  site-gentoo <user-args>`: `-l` after every `-L`, before caller args.
- Declare only real IUSE. `ssl/gui/tree-sitter` are unconditionally built →
  declared + `REQUIRED_USE`. `imagemagick` is unimplemented upstream → never
  declare it.

## Bump version (new Neomacs snapshot)

1. Set `NEOMACS_COMMIT` to the new commit; rename ebuild to
   `emacs-<emacs-version>_p<YYYYMMDD>.ebuild` where `<emacs-version>` is what
   the built image actually reports (`neomacs -batch -q --eval '(princ
   emacs-version)'`), not a tag.
2. Regenerate the crates tarball: `cd neomacs-bin && pycargoebuild -w
   --crate-tarball-path <out>`. If `Cargo.lock` gains/loses git deps, update
   `GIT_CRATES` and the `src_prepare` sed to match.
3. Place 3 distfiles in `${DISTDIR}`: `${P}.gh.tar.gz`,
   `${P}-crates.tar.xz`, `cosmic-text-<commit>.gh.tar.gz`. Run `ebuild
   <name>.ebuild manifest`.
4. Upload the crates tarball to the GitHub Release named `${P}` and set
   `SRC_URI` accordingly.

## Verify before committing

- `pkgcheck scan --repo .` → clean.
- `ebuild <name>.ebuild clean unpack` → 3 distfiles unpack, cosmic-text
  checkout lands in `work/`.
- `ebuild <name>.ebuild compile` → cargo build + xtask byte-compile finish
  (slow; run detached, it's the full Emacs lisp tree).
- Install to a scratch prefix and run the wrapper four ways: bare (site-gentoo
  loads, `ebuild-mode` activates), `--no-site-file` (site dirs still on
  load-path, byte-compile works), `--no-site-lisp` (clean), version probe
  (`--no-site-file -batch -q --eval '(princ emacs-version)'`).

## Done when

A new snapshot is *done* when `emerge` of the new PV succeeds end-to-end and
`eselect emacs set emacs-<slot>-neomacs` + the four wrapper checks pass on the
installed files — not when the ebuild merely parses.
