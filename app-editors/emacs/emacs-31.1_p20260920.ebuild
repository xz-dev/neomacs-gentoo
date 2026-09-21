# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"

# Git-sourced crate, fetched as a tarball via CARGO_CRATE_URIS and
# source-redirected to the unpacked checkout by cargo.eclass' GIT_CRATES
# machinery. Value: "uri;commit;checkout-dir" (%commit% is substituted).
declare -A GIT_CRATES=(
	[cosmic-text]='https://github.com/eval-exec/cosmic-text;5dd3fec8572e771794e3f203ab6780d828e9ce09;cosmic-text-%commit%'
	[dpi]='https://github.com/eval-exec/winit;6190d7c8df1bbc9533ecf61e137fe38b68c20ca1;winit-%commit%/dpi'
	[freetype-sys]='https://github.com/eval-exec/freetype-sys;a4eb0a7cf08d9b503bda7d7261c97f8973d34bf1;freetype-sys-%commit%'
	[winit-android]='https://github.com/eval-exec/winit;6190d7c8df1bbc9533ecf61e137fe38b68c20ca1;winit-%commit%/winit-android'
	[winit-appkit]='https://github.com/eval-exec/winit;6190d7c8df1bbc9533ecf61e137fe38b68c20ca1;winit-%commit%/winit-appkit'
	[winit-common]='https://github.com/eval-exec/winit;6190d7c8df1bbc9533ecf61e137fe38b68c20ca1;winit-%commit%/winit-common'
	[winit-core]='https://github.com/eval-exec/winit;6190d7c8df1bbc9533ecf61e137fe38b68c20ca1;winit-%commit%/winit-core'
	[winit-orbital]='https://github.com/eval-exec/winit;6190d7c8df1bbc9533ecf61e137fe38b68c20ca1;winit-%commit%/winit-orbital'
	[winit-uikit]='https://github.com/eval-exec/winit;6190d7c8df1bbc9533ecf61e137fe38b68c20ca1;winit-%commit%/winit-uikit'
	[winit-wayland]='https://github.com/eval-exec/winit;6190d7c8df1bbc9533ecf61e137fe38b68c20ca1;winit-%commit%/winit-wayland'
	[winit-web]='https://github.com/eval-exec/winit;6190d7c8df1bbc9533ecf61e137fe38b68c20ca1;winit-%commit%/winit-web'
	[winit-win32]='https://github.com/eval-exec/winit;6190d7c8df1bbc9533ecf61e137fe38b68c20ca1;winit-%commit%/winit-win32'
	[winit-x11]='https://github.com/eval-exec/winit;6190d7c8df1bbc9533ecf61e137fe38b68c20ca1;winit-%commit%/winit-x11'
	[winit]='https://github.com/eval-exec/winit;6190d7c8df1bbc9533ecf61e137fe38b68c20ca1;winit-%commit%/winit'
)

CRATES="
	ab_glyph@0.2.32
	ab_glyph_rasterizer@0.1.10
	addr2line@0.25.1
	adler2@2.0.1
	aes@0.9.1
	ahash@0.8.12
	aho-corasick@1.1.4
	aliasable@0.1.3
	aligned-vec@0.6.4
	aligned@0.4.3
	alloc-no-stdlib@2.0.4
	alloc-stdlib@0.2.2
	alloca@0.4.0
	allocator-api2@0.2.21
	allsorts@0.17.0
	alsa-sys@0.3.1
	alsa@0.9.1
	android-activity@0.6.1
	android-properties@0.2.2
	android_system_properties@0.1.5
	anes@0.1.6
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.104
	ar_archive_writer@0.5.1
	arbitrary@1.4.2
	arboard@3.6.1
	arg_enum_proc_macro@0.3.4
	arrayref@0.3.9
	arrayvec@0.7.6
	as-raw-xcb-connection@1.0.1
	as-slice@0.2.1
	ash@0.38.0+1.3.281
	asn1-rs-derive@0.6.0
	asn1-rs-impl@0.2.0
	asn1-rs@0.7.2
	atomic-waker@1.1.2
	atomic_refcell@0.1.14
	autocfg@1.5.0
	av-scenechange@0.14.1
	av1-grain@0.2.5
	avif-serialize@0.8.8
	axum-core@0.5.6
	axum@0.8.9
	backtrace@0.3.76
	base64@0.22.1
	base64@0.23.1
	bindgen@0.72.1
	bit-set@0.10.0
	bit-set@0.8.0
	bit-vec@0.8.0
	bit-vec@0.9.1
	bit_field@0.10.3
	bitflags@1.3.2
	bitflags@2.13.1
	bitreader@0.3.11
	bitstream-io@4.10.0
	block-buffer@0.12.0
	block-padding@0.4.2
	block2@0.6.2
	bon-macros@3.10.0
	bon@3.10.0
	borsh@1.5.7
	brotli-decompressor@5.0.0
	built@0.8.0
	bumpalo@3.20.2
	bytemuck@1.25.2
	bytemuck_derive@1.10.2
	byteorder-lite@0.1.0
	byteorder@1.5.0
	bytes@1.11.1
	calloop-wayland-source@0.4.1
	calloop@0.14.4
	cast@0.3.0
	cbc@0.2.1
	cc@1.4.5
	cesu8@1.1.0
	cexpr@0.6.0
	cfg-expr@0.17.2
	cfg-if@0.1.10
	cfg-if@1.0.4
	cfg_aliases@0.1.1
	cfg_aliases@0.2.2
	ciborium-io@0.2.2
	ciborium-ll@0.2.2
	ciborium@0.2.2
	cipher@0.5.2
	clang-sys@1.8.1
	clap@4.6.1
	clap_builder@4.6.0
	clap_derive@4.6.1
	clap_lex@1.1.0
	claxon@0.4.3
	clipboard-win@5.4.1
	cmov@0.5.4
	codespan-reporting@0.13.1
	color_quant@1.1.0
	colorchoice@1.0.5
	colored@3.1.1
	combine@4.6.7
	command-group@5.0.1
	concurrent-queue@2.5.0
	const-oid@0.10.2
	convert_case@0.10.0
	corcovado@0.5.5
	core-foundation-sys@0.8.7
	core-foundation@0.10.1
	core_maths@0.1.1
	coreaudio-rs@0.11.3
	coreaudio-sys@0.2.17
	cpal@0.15.3
	cpubits@0.1.1
	cpufeatures@0.3.0
	cranelift-assembler-x64-meta@0.134.3
	cranelift-assembler-x64@0.134.3
	cranelift-bforest@0.134.3
	cranelift-bitset@0.134.3
	cranelift-codegen-meta@0.134.3
	cranelift-codegen-shared@0.134.3
	cranelift-codegen@0.134.3
	cranelift-control@0.134.3
	cranelift-entity@0.134.3
	cranelift-frontend@0.134.3
	cranelift-isle@0.134.3
	cranelift-jit@0.134.3
	cranelift-module@0.134.3
	cranelift-native@0.134.3
	cranelift-object@0.134.3
	cranelift-srcgen@0.134.3
	crc32fast@1.5.0
	criterion-plot@0.8.2
	criterion@0.8.2
	crossbeam-channel@0.5.15
	crossbeam-deque@0.8.7
	crossbeam-epoch@0.9.20
	crossbeam-utils@0.8.21
	crossterm@0.29.0
	crossterm_winapi@0.9.1
	crunchy@0.2.4
	crypto-common@0.2.2
	ctutils@0.4.2
	cty@0.2.2
	cursor-icon@1.2.0
	darling@0.24.1
	darling_core@0.24.1
	darling_macro@0.24.1
	dasp_sample@0.11.0
	data-encoding@2.11.0
	data-url@0.3.2
	dbus@0.9.11
	debugid@0.8.0
	der-parser@10.0.0
	deranged@0.5.8
	derive_more-impl@2.1.1
	derive_more@2.1.1
	digest@0.11.3
	dirs-sys@0.5.0
	dirs@6.0.0
	dispatch2@0.3.1
	displaydoc@0.2.6
	dissimilar@1.0.11
	dlib@0.5.3
	dns-lookup@4.0.1
	document-features@0.2.12
	downcast-rs@1.2.1
	dwrote@0.11.5
	either@1.15.0
	encoding_rs@0.8.35
	enumflags2@0.7.12
	enumflags2_derive@0.7.12
	equator-macro@0.4.2
	equator@0.4.2
	equivalent@1.0.2
	errno@0.3.14
	error-code@3.3.2
	euclid@0.22.14
	expect-test@1.5.1
	exr@1.74.0
	fallible-iterator@0.3.0
	fallible-streaming-iterator@0.1.9
	fastrand@2.4.1
	fax@0.2.7
	fdeflate@0.3.7
	filedescriptor@0.8.3
	filetime@0.2.29
	find-msvc-tools@0.1.12
	findshlibs@0.10.2
	flate2@1.1.10
	float-cmp@0.9.0
	fnv@1.0.7
	foldhash@0.2.0
	font-types@0.11.3
	fontconfig-parser@0.5.8
	fontconfig@0.11.0
	fontdb@0.23.0
	form_urlencoded@1.2.2
	freetype-rs@0.38.0
	fs4@1.1.0
	fuchsia-zircon-sys@0.3.3
	fuchsia-zircon@0.3.3
	futures-channel@0.3.32
	futures-core@0.3.32
	futures-executor@0.3.32
	futures-io@0.3.34
	futures-macro@0.3.32
	futures-sink@0.3.32
	futures-task@0.3.32
	futures-util@0.3.32
	gethostname@1.1.0
	getrandom@0.2.17
	getrandom@0.3.4
	getrandom@0.4.3
	gif@0.14.2
	gimli@0.32.3
	gimli@0.33.0
	gio-sys@0.22.8
	gio@0.22.8
	gl_generator@0.14.0
	glib-macros@0.22.6
	glib-sys@0.22.6
	glib@0.22.8
	glob@0.3.3
	glow@0.17.0
	glutin_wgl_sys@0.6.1
	glyph-names@0.2.0
	gobject-sys@0.22.6
	gpu-allocator@0.28.0
	gstreamer-allocators-sys@0.25.0
	gstreamer-allocators@0.25.3
	gstreamer-app-sys@0.25.0
	gstreamer-app@0.25.0
	gstreamer-audio-sys@0.25.3
	gstreamer-audio@0.25.3
	gstreamer-base-sys@0.25.0
	gstreamer-base@0.25.0
	gstreamer-pbutils-sys@0.25.2
	gstreamer-pbutils@0.25.2
	gstreamer-sys@0.25.0
	gstreamer-video-sys@0.25.0
	gstreamer-video@0.25.3
	gstreamer@0.25.3
	half@2.7.1
	harfrust@0.5.2
	hashbrown@0.16.1
	hashbrown@0.17.0
	hashlink@0.12.1
	heck@0.4.1
	heck@0.5.0
	hermit-abi@0.3.9
	hermit-abi@0.5.2
	hmac@0.13.0
	home@0.5.12
	hostname@0.4.2
	hound@3.5.1
	htmlize@1.1.0
	http-body-util@0.1.5
	http-body@1.1.0
	http@1.4.2
	httparse@1.10.1
	httpdate@1.0.3
	hybrid-array@0.4.11
	hyper-util@0.1.20
	hyper@1.10.1
	icu_collections@2.2.0
	icu_locale_core@2.2.0
	icu_normalizer@2.2.0
	icu_normalizer_data@2.2.0
	icu_properties@2.2.0
	icu_properties_data@2.2.0
	icu_provider@2.2.0
	ident_case@1.0.1
	idna@1.1.0
	idna_adapter@1.2.2
	image-webp@0.2.4
	image@0.25.10
	imagesize@0.14.0
	imagesize@0.15.0
	imgref@1.12.1
	indexmap@2.14.0
	inferno@0.11.21
	inferno@0.12.8
	inotify-sys@0.1.8
	inotify@0.11.5
	inout@0.2.2
	interpolate_name@0.2.4
	io-lifetimes@1.0.11
	iovec@0.1.4
	is-terminal@0.4.17
	is_terminal_polyfill@1.70.2
	itertools@0.13.0
	itertools@0.14.0
	itertools@0.15.0
	itoa@1.0.18
	jni-macros@0.22.4
	jni-sys-macros@0.4.1
	jni-sys@0.3.1
	jni-sys@0.4.1
	jni@0.21.1
	jni@0.22.4
	jobserver@0.1.34
	js-sys@0.3.105
	keyboard-types@0.8.3
	keysymdefs@0.2.0
	khronos-egl@6.0.0
	khronos_api@3.1.0
	kstring@2.0.2
	kurbo@0.13.0
	lazy_static@1.5.0
	lebe@0.5.3
	lewton@0.10.2
	libc@0.2.189
	libdbus-sys@0.2.7
	libfuzzer-sys@0.4.12
	libloading@0.8.9
	libloading@0.9.0
	libm@0.2.16
	libmimalloc-sys@0.1.49
	libredox@0.1.23
	libsqlite3-sys@0.38.2
	libudev-sys@0.1.4
	libz-sys@1.1.28
	linear-map@1.2.0
	linebender_resource_handle@0.1.1
	linux-perf-data@0.13.0
	linux-perf-event-reader@0.10.2
	linux-raw-sys@0.12.1
	linux-raw-sys@0.4.15
	litemap@0.8.2
	litrs@1.0.0
	lock_api@0.4.14
	log@0.4.29
	loop9@0.1.5
	mach2@0.4.3
	malachite-base@0.9.1
	malachite-float@0.9.1
	malachite-nz@0.9.1
	malachite-q@0.9.1
	malachite@0.9.1
	matchers@0.2.0
	matchit@0.8.4
	maybe-rayon@0.1.1
	md-5@0.11.0
	memchr@2.8.3
	memmap2@0.9.11
	mimalloc@0.1.52
	mime@0.3.17
	minimal-lexical@0.2.1
	miniz_oxide@0.8.9
	miniz_oxide@0.9.1
	mio@1.2.0
	miow@0.5.0
	miow@0.6.1
	moxcms@0.8.1
	muldiv@1.0.1
	naga-types@30.0.0
	naga@30.0.1
	ndk-context@0.1.1
	ndk-sys@0.5.0+25.2.9519653
	ndk-sys@0.6.0+11769913
	ndk@0.8.0
	ndk@0.9.0
	network-interface@2.0.5
	new_debug_unreachable@1.0.6
	nix@0.26.4
	nix@0.27.1
	nix@0.28.0
	no_std_io2@0.9.4
	nom@7.1.3
	nom@8.0.0
	noop_proc_macro@0.3.0
	ntapi@0.4.3
	nu-ansi-term@0.50.3
	num-bigint@0.4.6
	num-conv@0.2.2
	num-derive@0.4.2
	num-format@0.4.4
	num-integer@0.1.46
	num-rational@0.4.2
	num-traits@0.2.19
	num_enum@0.7.6
	num_enum_derive@0.7.6
	num_threads@0.1.7
	objc2-app-kit@0.3.2
	objc2-av-foundation@0.3.2
	objc2-avf-audio@0.3.2
	objc2-cloud-kit@0.3.2
	objc2-core-audio-types@0.3.2
	objc2-core-audio@0.3.2
	objc2-core-data@0.3.2
	objc2-core-foundation@0.3.2
	objc2-core-graphics@0.3.2
	objc2-core-image@0.3.2
	objc2-core-media@0.3.2
	objc2-core-text@0.3.2
	objc2-core-video@0.3.2
	objc2-encode@4.1.0
	objc2-foundation@0.3.2
	objc2-image-io@0.3.2
	objc2-io-kit@0.3.2
	objc2-io-surface@0.3.2
	objc2-javascript-core@0.3.2
	objc2-media-toolbox@0.3.2
	objc2-metal@0.3.2
	objc2-open-directory@0.3.2
	objc2-quartz-core@0.3.2
	objc2-security@0.3.2
	objc2-system-configuration@0.3.2
	objc2-ui-kit@0.3.2
	objc2-web-kit@0.3.2
	objc2@0.6.4
	object@0.37.3
	object@0.39.1
	oboe-sys@0.6.1
	oboe@0.6.1
	ogg@0.8.0
	oid-registry@0.8.1
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	oorandom@11.1.5
	option-ext@0.2.0
	option-operations@0.6.1
	orbclient@0.4.6
	ordered-float@5.3.0
	os_pipe@1.2.3
	ouroboros@0.18.5
	ouroboros_macro@0.18.5
	owned_ttf_parser@0.25.1
	page_size@0.6.0
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	paste@1.0.15
	pastey@0.1.1
	pastey@0.2.2
	pathfinder_geometry@0.5.1
	pathfinder_simd@0.5.6
	percent-encoding@2.3.2
	phf@0.11.3
	phf@0.13.1
	phf_codegen@0.11.3
	phf_codegen@0.13.1
	phf_generator@0.11.3
	phf_generator@0.13.1
	phf_shared@0.11.3
	phf_shared@0.13.1
	pico-args@0.5.0
	pin-project-internal@1.1.11
	pin-project-lite@0.2.17
	pin-project@1.1.11
	pkg-config@0.3.33
	plain@0.2.3
	plotters-backend@0.3.7
	plotters-svg@0.3.7
	plotters@0.3.7
	png@0.18.1
	polling@3.11.0
	pollster@1.0.1
	portable-atomic-util@0.2.7
	portable-atomic@1.13.1
	portable-pty@0.9.0
	potential_utf@0.1.5
	powerfmt@0.2.0
	pp-rs@0.2.1
	pprof@0.15.0
	ppv-lite86@0.2.21
	presser@0.3.1
	prettyplease@0.2.37
	prettyplease@0.3.0
	proc-macro-crate@3.5.0
	proc-macro2-diagnostics@0.10.1
	proc-macro2@1.0.106
	profiling-procmacros@1.0.18
	profiling@1.0.17
	proptest@1.11.0
	prost-derive@0.14.4
	prost@0.14.4
	protobuf-codegen@3.7.2
	protobuf-parse@3.7.2
	protobuf-support@3.7.2
	protobuf@3.7.2
	psm@0.1.31
	pty-process@0.5.3
	pxfm@0.1.29
	qoi@0.4.1
	quick-error@1.2.3
	quick-error@2.0.1
	quick-xml@0.26.0
	quick-xml@0.39.2
	quick-xml@0.41.0
	quote@1.0.45
	r-efi@5.3.0
	r-efi@6.0.0
	rand@0.8.6
	rand@0.9.4
	rand_chacha@0.3.1
	rand_chacha@0.9.0
	rand_core@0.6.4
	rand_core@0.9.5
	rand_xorshift@0.4.0
	range-alloc@0.1.5
	rangemap@1.7.1
	rav1e@0.8.1
	ravif@0.13.0
	raw-window-handle@0.6.2
	raw-window-metal@1.1.0
	rayon-core@1.13.0
	rayon@1.12.0
	read-fonts@0.37.0
	redox_event@0.4.8
	redox_syscall@0.5.18
	redox_syscall@0.9.4
	redox_users@0.5.2
	regalloc2@0.15.1
	regex-automata@0.4.18
	regex-syntax@0.8.10
	regex@1.12.3
	region@3.0.2
	renderdoc-sys@1.1.0
	resvg@0.47.0
	rgb@0.8.53
	ring@0.17.14
	rio-grapheme-width@0.5.5
	rio-graphics@0.5.5
	rio-vt@0.5.5
	rodio@0.20.1
	roxmltree@0.20.0
	roxmltree@0.21.1
	rsqlite-vfs@0.1.1
	rusqlite@0.40.2
	rustc-demangle@0.1.28
	rustc-hash@1.1.0
	rustc-hash@2.1.3
	rustc_version@0.4.1
	rusticata-macros@4.1.0
	rustix@0.38.44
	rustix@1.1.4
	rustls-pki-types@1.15.1
	rustls-webpki@0.103.15
	rustls@0.23.45
	rustversion@1.0.23
	rusty-fork@0.3.1
	rustybuzz@0.20.1
	ruzstd@0.8.3
	ryu@1.0.23
	safe_arch@1.0.0
	same-file@1.0.6
	scoped-tls@1.0.1
	scopeguard@1.2.0
	sctk-adwaita@0.12.0
	self_cell@1.2.2
	semver@1.0.28
	serde@1.0.229
	serde_core@1.0.229
	serde_derive@1.0.229
	serde_json@1.0.151
	serde_path_to_error@0.1.20
	serde_spanned@1.1.1
	serde_urlencoded@0.7.1
	serial2@0.2.36
	sha1@0.11.0
	sha2@0.11.0
	sharded-slab@0.1.7
	shared_library@0.1.9
	shell-words@1.1.1
	shlex@1.3.0
	shlex@2.0.1
	signal-hook-mio@0.2.5
	signal-hook-registry@1.4.8
	signal-hook@0.3.18
	signal-hook@0.4.4
	simd-adler32@0.3.9
	simd_cesu8@1.1.1
	simd_helpers@0.1.0
	simdutf8@0.1.5
	simdutf@0.7.0
	simplecss@0.2.2
	siphasher@1.0.2
	skrifa@0.40.0
	slab@0.4.12
	slotmap@1.1.1
	smallvec@1.15.2
	smithay-client-toolkit@0.20.0
	smithay-client-toolkit@0.21.1
	smithay-clipboard@0.7.3
	smol_str@0.3.6
	socket2@0.6.5
	spin@0.10.1
	spirv@0.4.0+sdk-1.4.341.0
	sqlite-wasm-rs@0.5.5
	stable_deref_trait@1.2.1
	stacker@0.1.24
	static_assertions@1.1.0
	str_stack@0.1.1
	streaming-iterator@0.1.9
	strict-num@0.1.1
	strsim@0.11.1
	strum@0.28.0
	strum_macros@0.28.0
	subtle@2.6.1
	svgtypes@0.16.1
	swash@0.2.10
	symbolic-common@12.18.3
	symbolic-demangle@12.18.3
	symlink@0.1.0
	symphonia-bundle-mp3@0.5.5
	symphonia-core@0.5.5
	symphonia-metadata@0.5.5
	symphonia@0.5.5
	syn@2.0.119
	syn@3.0.4
	sync_wrapper@1.0.2
	synstructure@0.13.2
	sys-locale@0.3.2
	sysinfo@0.39.6
	system-deps@7.0.8
	tar@0.4.46
	target-lexicon@0.12.16
	target-lexicon@0.13.5
	teletypewriter@0.5.5
	tempfile@3.27.0
	termcolor@1.4.1
	thiserror-impl@1.0.69
	thiserror-impl@2.0.20
	thiserror@1.0.69
	thiserror@2.0.20
	thread_local@1.1.9
	tiff@0.11.3
	tikv-jemalloc-sys@0.7.1+5.3.1-0-g81034ce1f1373e37dc865038e1bc8eeecf559ce8
	tikv-jemallocator@0.7.0
	time-core@0.1.9
	time-macros@0.2.32
	time@0.3.55
	tiny-skia-path@0.12.0
	tiny-skia@0.12.0
	tinystr@0.8.3
	tinytemplate@1.2.1
	tinyvec@1.11.0
	tinyvec_macros@0.1.1
	tl@0.7.8
	tokio-macros@2.7.0
	tokio-stream@0.1.19
	tokio@1.53.1
	toml@1.1.2+spec-1.1.0
	toml_datetime@1.1.1+spec-1.1.0
	toml_edit@0.25.11+spec-1.1.0
	toml_parser@1.1.2+spec-1.1.0
	toml_writer@1.1.1+spec-1.1.0
	tower-layer@0.3.3
	tower-service@0.3.3
	tower@0.5.3
	tracing-appender@0.2.5
	tracing-attributes@0.1.31
	tracing-core@0.1.36
	tracing-log@0.2.0
	tracing-subscriber@0.3.23
	tracing-test-macro@0.2.6
	tracing-test@0.2.6
	tracing@0.1.44
	tree-sitter-json@0.24.8
	tree-sitter-language@0.1.8
	tree-sitter@0.27.0
	ttf-parser@0.25.1
	twox-hash@2.1.2
	typenum@1.20.0
	ucd-trie@0.1.7
	udev@0.9.3
	unarray@0.1.4
	unicode-bidi-mirroring@0.4.0
	unicode-bidi@0.3.18
	unicode-canonical-combining-class@1.0.0
	unicode-ccc@0.4.0
	unicode-general-category@1.1.0
	unicode-ident@1.0.24
	unicode-joining-type@1.0.0
	unicode-linebreak@0.1.5
	unicode-properties@0.1.4
	unicode-script@0.5.8
	unicode-segmentation@1.13.2
	unicode-vo@0.1.0
	unicode-width-16@0.1.0
	unicode-width@0.2.2
	unicode-xid@0.2.6
	unicode_names2@3.1.0
	unicode_names2_generator@3.1.0
	untrusted@0.9.0
	ureq-proto@0.6.1
	ureq@3.4.0
	url@2.5.8
	usvg@0.47.0
	utf8-zero@0.8.1
	utf8_iter@1.0.4
	utf8parse@0.2.2
	uuid@1.23.5
	v_frame@0.3.9
	valuable@0.1.1
	vcpkg@0.2.15
	vergen-gitcl@10.0.3
	vergen-lib@10.0.3
	vergen@10.0.3
	version-compare@0.2.1
	version_check@0.9.5
	vt100@0.16.2
	vte@0.15.0
	wait-timeout@0.2.1
	walkdir@2.5.0
	wasi@0.11.1+wasi-snapshot-preview1
	wasi@0.14.7+wasi-0.2.4
	wasip2@1.0.3+wasi-0.2.9
	wasite@1.0.2
	wasm-bindgen-futures@0.4.78
	wasm-bindgen-macro-support@0.2.128
	wasm-bindgen-macro@0.2.128
	wasm-bindgen-shared@0.2.128
	wasm-bindgen@0.2.128
	wasmtime-internal-core@47.0.3
	wasmtime-internal-jit-icache-coherence@47.0.3
	wayland-backend@0.3.17
	wayland-client@0.31.15
	wayland-csd-frame@0.3.0
	wayland-cursor@0.31.14
	wayland-protocols-experimental@20250721.0.1
	wayland-protocols-experimental@20251230.0.3
	wayland-protocols-misc@0.3.12
	wayland-protocols-plasma@0.3.12
	wayland-protocols-wlr@0.3.12
	wayland-protocols@0.32.13
	wayland-scanner@0.31.10
	wayland-sys@0.31.11
	web-sys@0.3.105
	web-time@1.1.0
	webpki-roots@1.0.9
	webview2-com-macros@0.8.1
	webview2-com-sys@0.39.1
	webview2-com@0.39.1
	weezl@0.1.12
	wgpu-core-deps-apple@30.0.0
	wgpu-core-deps-emscripten@30.0.0
	wgpu-core-deps-windows-linux-android@30.0.0
	wgpu-core@30.0.0
	wgpu-hal@30.0.1
	wgpu-naga-bridge@30.0.0
	wgpu-types@30.0.0
	wgpu@30.0.1
	which@4.4.2
	whoami@2.1.3
	wide@1.4.0
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-collections@0.3.2
	windows-core@0.54.0
	windows-core@0.62.2
	windows-future@0.3.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-numerics@0.3.1
	windows-result@0.1.2
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.42.0
	windows-sys@0.45.0
	windows-sys@0.48.0
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-sys@0.60.2
	windows-sys@0.61.2
	windows-targets@0.42.2
	windows-targets@0.48.5
	windows-targets@0.52.6
	windows-targets@0.53.5
	windows-threading@0.2.1
	windows-version@0.1.7
	windows@0.42.0
	windows@0.54.0
	windows@0.62.2
	windows_aarch64_gnullvm@0.42.2
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_gnullvm@0.53.1
	windows_aarch64_msvc@0.42.2
	windows_aarch64_msvc@0.48.5
	windows_aarch64_msvc@0.52.6
	windows_aarch64_msvc@0.53.1
	windows_i686_gnu@0.42.2
	windows_i686_gnu@0.48.5
	windows_i686_gnu@0.52.6
	windows_i686_gnu@0.53.1
	windows_i686_gnullvm@0.52.6
	windows_i686_gnullvm@0.53.1
	windows_i686_msvc@0.42.2
	windows_i686_msvc@0.48.5
	windows_i686_msvc@0.52.6
	windows_i686_msvc@0.53.1
	windows_x86_64_gnu@0.42.2
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnu@0.53.1
	windows_x86_64_gnullvm@0.42.2
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_gnullvm@0.53.1
	windows_x86_64_msvc@0.42.2
	windows_x86_64_msvc@0.48.5
	windows_x86_64_msvc@0.52.6
	windows_x86_64_msvc@0.53.1
	winnow@1.0.2
	winreg@0.10.1
	winreg@0.56.0
	wio@0.2.2
	wit-bindgen@0.57.1
	writeable@0.6.3
	x11-dl@2.21.0
	x11rb-protocol@0.13.2
	x11rb@0.13.2
	x509-parser@0.18.1
	xattr@1.6.1
	xcursor@0.3.10
	xkbcommon-dl@0.4.2
	xkeysym@0.2.1
	xml-rs@0.8.28
	xmlwriter@0.1.0
	y4m@0.8.0
	yansi@1.0.1
	yazi@0.2.1
	yeslogic-fontconfig-sys@6.0.1
	yoke-derive@0.8.2
	yoke@0.8.3
	zeno@0.3.3
	zerocopy-derive@0.8.48
	zerocopy@0.8.48
	zerofrom-derive@0.1.7
	zerofrom@0.1.8
	zeroize@1.8.2
	zerotrie@0.2.4
	zerovec-derive@0.11.3
	zerovec@0.11.6
	zlib-rs@0.6.7
	zmij@1.0.21
	zune-core@0.5.1
	zune-inflate@0.2.54
	zune-jpeg@0.5.15
"

inherit cargo desktop toolchain-funcs xdg

DESCRIPTION="Neomacs (Rust Emacs fork) packaged as app-editors/emacs"
HOMEPAGE="https://github.com/eval-exec/neomacs"

# Pinned snapshot. PV records the emacs-version the built image reports
# (31.1 per gnu_emacs_version!(31,1); confirm on first build), not an
# upstream tag. Bump the commit + date together.
NEOMACS_COMMIT="a0caa5425795595705b3aed48fbda7a7deca0400"
SRC_URI="
	https://github.com/eval-exec/neomacs/archive/${NEOMACS_COMMIT}.tar.gz -> ${P}.gh.tar.gz
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

	# The git dependencies pinned in upstream's own [patch.crates-io]
	# (cosmic-text, freetype-sys) can't be fetched in offline builds, so
	# redirect each patch entry to the GIT_CRATES checkout cargo_crate_uris
	# already downloaded into ${WORKDIR} (same mechanism as gentoo-zh/codex).
	# winit is a [dependencies] git dep and is patched by cargo.eclass'
	# GIT_CRATES machinery itself -- do NOT sed it here.
	local crate crate_dir
	for crate in cosmic-text freetype-sys; do
		crate_dir="$(gen_git_crate_dir "${crate}")"
		sed -i \
			-e 's|'"${crate}"' = { git = "[^"]*", rev = "[^"]*" }|'"${crate}"' = { path = "'"${crate_dir}"'" }|' \
			Cargo.toml || die
		grep -q "${crate} = { path = " Cargo.toml \
			|| die "${crate} was not redirected to the local checkout"
	done
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
	# LC_ALL=C: xtask greps `readelf --dynamic` output for the literal
	# English "Shared library: [libgst...]"; under a non-English locale
	# readelf prints a translated tag (e.g. zh_CN "共享库") and the
	# LinkedGstreamer contract check fails even though the libs are linked.
	LC_ALL=C cargo_env cargo xtask \
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

	# Upstream ships its own desktop entry + window icon under
	# crates/neomacs-display-runtime/assets (the old top-level assets/
	# logo-128.png is gone). Reuse them, retargeted at our wrapper name so
	# the launcher runs eselect's ${EMACS_SUFFIX} (which the desktop file's
	# bare `neomacs` Exec would bypass).
	insopts -m0644
	sed -e 's|^Exec=neomacs|Exec='"${EMACS_SUFFIX}"'|' \
		-e 's|^Icon=neomacs|Icon='"${EMACS_SUFFIX}"'|' \
		crates/neomacs-display-runtime/assets/neomacs.desktop \
		> "${T}/${EMACS_SUFFIX}.desktop" || die
	domenu "${T}/${EMACS_SUFFIX}.desktop"
	newicon -s scalable \
		crates/neomacs-display-runtime/assets/window-icon.svg \
		"${EMACS_SUFFIX}.svg"

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
