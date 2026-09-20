# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"

# Git-sourced crate, fetched as a tarball via CARGO_CRATE_URIS and
# source-redirected to the unpacked checkout by cargo.eclass' GIT_CRATES
# machinery. Value: "uri;commit;checkout-dir" (%commit% is substituted).
declare -A GIT_CRATES=(
	[cosmic-text]='https://github.com/eval-exec/cosmic-text;5dd3fec8572e771794e3f203ab6780d828e9ce09;cosmic-text-%commit%'
)

inherit cargo desktop toolchain-funcs xdg

DESCRIPTION="Neomacs (Rust Emacs fork) packaged as app-editors/emacs"
HOMEPAGE="https://github.com/eval-exec/neomacs"

# Pinned snapshot. PV records the emacs-version the built image reports
# (31.0.50), not an upstream tag. Bump the commit + date together.
NEOMACS_COMMIT="57eebb953f7f290865e3c3eefd3bde679852b671"
SRC_URI="
	https://github.com/eval-exec/neomacs/archive/${NEOMACS_COMMIT}.tar.gz -> ${P}.gh.tar.gz
	https://github.com/xz-dev/neomacs-gentoo/releases/download/${P}/${P}-crates.tar.xz
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/neomacs-${NEOMACS_COMMIT}"

LICENSE="GPL-3+ FDL-1.3+ CC-BY-SA-3.0 CC-BY-SA-4.0 CC-BY-4.0 HPND PCRE PSF-2 unicode W3C"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0
	CC0-1.0 CDLA-Permissive-2.0 ISC LGPL-3 MIT MPL-2.0 UoI-NCSA
	Unicode-3.0 Unicode-DFS-2016 ZLIB
"

# Coexists with GNU Emacs SLOT=31: `:*` consumers accept any slot.
SLOT="31-neomacs"
KEYWORDS="~amd64"

# jit/terminal/video map to real cargo features. ssl/gui/tree-sitter are
# unconditionally built into neovm-core (rustls, winit+wgpu, tree-sitter
# crates) and exposed so USE-flagged atoms like app-editors/emacs[ssl]
# resolve; REQUIRED_USE pins them on because there is no flag to disable
# them. imagemagick is deliberately NOT declared — it is unimplemented
# upstream, so consumers requiring it simply won't resolve.
IUSE="+jit +ssl +gui +terminal +tree-sitter +video"
REQUIRED_USE="gui ssl tree-sitter"

RESTRICT="test"

DEPEND="
	dev-libs/wayland
	media-libs/fontconfig
	media-libs/mesa
	dev-db/sqlite:3
	media-libs/vulkan-loader[X,wayland]
	sys-libs/ncurses:=
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	video? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
	)
"
# eselect-emacs owns /usr/bin/emacs (we must NOT ship it as a real file).
# emacs-common provides subdirs.el + /etc/emacs/site-start.el so the
# site-gentoo aggregate exists for our wrapper to load.
RDEPEND="
	${DEPEND}
	app-eselect/eselect-emacs
	app-emacs/emacs-common
"
BDEPEND="virtual/pkgconfig"
IDEPEND="app-eselect/eselect-emacs"

DOCS=( BUGS CONTRIBUTE README.md )

EMACS_SUFFIX="emacs-${SLOT}"

src_unpack() {
	cargo_src_unpack
}

gen_git_crate_dir() {
	# Mirror cargo.eclass GIT_CRATES checkout location (eclass L442).
	IFS=';' read -r crate_uri commit crate_dir <<<"${GIT_CRATES[$1]}"
	echo "${WORKDIR}/${crate_dir//%commit%/${commit}}"
}

src_prepare() {
	default

	# Prefer Gentoo's system sqlite over rusqlite/libsqlite3-sys' bundled copy.
	sed -i -e 's/"bundled"//' Cargo.toml || die

	# The only git dependency is cosmic-text, pinned in [patch.crates-io].
	# In offline builds the git source can't be fetched, so redirect that
	# patch entry to the GIT_CRATES checkout cargo_crate_uris already
	# downloaded into ${WORKDIR} (same mechanism as gentoo-zh/codex).
	local cosmic_dir
	cosmic_dir="$(gen_git_crate_dir cosmic-text)"
	sed -i \
		-e 's|cosmic-text = { git = "[^"]*", rev = "[^"]*" }|cosmic-text = { path = "'"${cosmic_dir}"'" }|' \
		Cargo.toml || die
	grep -q 'cosmic-text = { path = ' Cargo.toml \
		|| die "cosmic-text was not redirected to the local checkout"
}

src_configure() {
	local myfeatures=(
		$(usev jit)
		$(usev terminal neo-term)
		$(usev video)
	)
	cargo_src_configure --no-default-features
}

src_compile() {
	# Upstream's build script probes ncurses for the library target, but the
	# final binary also needs the full ncursesw linker set for termcap symbols.
	local ncurses_libs ncurses_link
	ncurses_libs=$("$(tc-getPKG_CONFIG)" --libs ncursesw) || die "failed to query ncursesw libs"
	for ncurses_link in ${ncurses_libs}; do
		RUSTFLAGS+=" -C link-arg=${ncurses_link}"
	done

	# The cargo package is still called "neomacs" even though PN=emacs.
	cargo_src_compile -p neomacs

	# xtask patches the pdump fingerprint into the freshly linked binary,
	# then dumps the matching image. Skipping this leaves a placeholder
	# fingerprint in the binary -> "pdump fingerprint mismatch" at startup.
	cargo_env cargo xtask \
		fresh-build \
		--release \
		--skip-build \
		--bin-dir "$(cargo_target_dir)" \
		--runtime-root "${S}" || die
}

src_install() {
	local target_dir=$(cargo_target_dir)
	local libexec_dir="/usr/libexec/emacs/${PV}"
	local runtime_dir="/usr/share/emacs/${PV}"

	exeinto "${libexec_dir}"
	doexe "${target_dir}/neomacs"

	insinto "${libexec_dir}"
	doins "${target_dir}/neomacs.pdump"

	# eselect discovers /usr/bin/emacs-[0-9]*. Wrapper bridges Gentoo
	# site-lisp: -L the site-lisp root AND every subdir (mirrors GNU's
	# subdirs.el expansion, which survives --no-site-file), then load the
	# site-gentoo aggregate. Both are skipped when the caller asks for a
	# clean run so eclass byte-compile (--no-site-file) keeps site dirs on
	# load-path while -Q/--no-site-lisp stay clean.
	cat > "${T}/${EMACS_SUFFIX}" <<-EOF || die
		#!/bin/sh
		export NEOMACS_RUNTIME_ROOT="\${NEOMACS_RUNTIME_ROOT:-${EPREFIX}${runtime_dir}}"
		_site_lisp="${EPREFIX}/usr/share/emacs/site-lisp"
		# -Q implies --no-site-file (GNU). --no-site-lisp removes the
		# site-lisp dir entirely; --no-site-file only skips site-start/
		# site-gentoo init but keeps site-lisp subdirs on load-path (GNU
		# subdirs.el behaviour).
		_no_site_lisp=0 _no_site_file=0
		for _a in "\$@"; do
			case "\$_a" in
				-Q|--quick) _no_site_file=1 ;;
				--no-site-lisp) _no_site_lisp=1 ;;
				--no-site-file|-nl) _no_site_file=1 ;;
			esac
		done
		if [ \$_no_site_lisp -eq 0 ]; then
			# Build argv so the order is: -L <subdirs> -l site-gentoo <user args>.
			# Prepends run last-to-first: add the site-gentoo load first so it
			# lands after every -L (load-path must contain site-lisp before the
			# aggregate is loaded) but before the caller's own -l/-L args.
			if [ \$_no_site_file -eq 0 ]; then
				set -- -l site-gentoo "\$@"
			fi
			for _d in "\$_site_lisp"/*/; do
				[ -d "\$_d" ] && set -- -L "\${_d%/}" "\$@"
			done
			set -- -L "\$_site_lisp" "\$@"
		fi
		exec "${EPREFIX}${libexec_dir}/neomacs" "\$@"
	EOF
	newbin "${T}/${EMACS_SUFFIX}" "${EMACS_SUFFIX}"

	insinto "${runtime_dir}"
	doins -r etc lisp

	newicon -s 128 assets/logo-128.png "${EMACS_SUFFIX}.png"
	newicon -s scalable assets/window-icon.svg "${EMACS_SUFFIX}.svg"
	make_desktop_entry \
		--eapi9 \
		-n "Neomacs (Emacs ${SLOT})" \
		-i "${EMACS_SUFFIX}" \
		-c "Development;TextEditor" \
		-e "MimeType=text/plain;text/x-c;text/x-c++;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-makefile;text/x-python;text/x-rust;application/x-shellscript;" \
		-e "StartupWMClass=Neomacs" \
		"${EMACS_SUFFIX}"

	einstalldocs
	dodoc -r docs
}

pkg_postinst() {
	xdg_pkg_postinst
	# Wire /usr/bin/emacs only if unset; never steal an existing choice.
	eselect --root="${ROOT}" emacs update ifunset

	elog "Neomacs (SLOT ${SLOT}) is an EXPERIMENTAL Emacs replacement, not a"
	elog "drop-in GNU Emacs substitute."
	elog "To select it as /usr/bin/emacs:  eselect emacs set ${EMACS_SUFFIX}"
	elog "To revert to GNU Emacs:           eselect emacs set emacs-31"
	elog ""
	elog "Known gaps: imagemagick image loading is unimplemented upstream, so"
	elog "consumers needing app-editors/emacs[imagemagick] will not resolve;"
	elog "emacsclient/etags/ctags/ebrowse are not provided."
	if use video; then
		elog "Install GStreamer plugin packages as needed for media formats."
	fi
}

pkg_postrm() {
	xdg_pkg_postrm
	eselect --root="${ROOT}" emacs update ifunset
}
