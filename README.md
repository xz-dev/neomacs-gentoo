# neomacs-gentoo

Gentoo overlay packaging [Neomacs](https://github.com/eval-exec/neomacs) — a
GPU-powered Emacs fork rewriting Emacs internals in Rust — **under the
`app-editors/emacs` atom** so Emacs dependencies resolve to it. Coexists with
GNU Emacs; you pick the active `/usr/bin/emacs` via eselect.

Experimental: Neomacs is alpha software, not a drop-in GNU Emacs substitute.
Keep GNU Emacs installed for rollback.

## Use

```sh
# add the overlay
eselect repository add neomacs-gentoo git https://github.com/xz-dev/neomacs-gentoo.git
emaint sync -r neomacs-gentoo

# install (a new slot beside GNU emacs:31)
emerge app-editors/emacs:31-neomacs

# point /usr/bin/emacs at neomacs
eselect emacs set emacs-31-neomacs

# revert to GNU
eselect emacs set emacs-31
```

`eselect emacs list` shows both `emacs-31` (GNU) and `emacs-31-neomacs`.

## What gets installed

- `/usr/bin/emacs-31-neomacs` — wrapper exporting `NEOMACS_RUNTIME_ROOT` and
  bridging Gentoo site-lisp (`-L` the site-lisp root and every subdir, `-l
  site-gentoo` unless `-Q`/`--no-site-file`/`--no-site-lisp`).
- `/usr/libexec/emacs/${PV}/{neomacs,neomacs.pdump}` — binary + dumped image.
- `/usr/share/emacs/${PV}/{etc,lisp}` — runtime Lisp tree.

## Known gaps

- `imagemagick` image loading is unimplemented upstream → consumers needing
  `app-editors/emacs[imagemagick]` will not resolve.
- `emacsclient` / `etags` / `ctags` / `ebrowse` are not provided; selecting
  neomacs drops the generic `/usr/bin/emacsclient` symlink until you re-select
  a GNU slot.

## Layout

- `app-editors/emacs/` — the ebuild (pinned commit + offline crates + GIT_CRATES
  for the one git dep).
- `DESIGN.md` — why it's built this way (dependency model, eselect/site-lisp
  mechanics, experiments, publish flow). Read it before changing the ebuild.
- `AGENTS.md` — maintainer runbook for AI agents.
