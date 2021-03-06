# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

LUA_COMPAT=( lua5-1 luajit )
LUA_REQ_USE="deprecated(+)"

inherit lua-single flag-o-matic systemd

DESCRIPTION="Prosody is a flexible communications server for Jabber/XMPP written in Lua"
HOMEPAGE="https://prosody.im/"
SRC_URI="https://prosody.im/downloads/source/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="ipv6 libevent mysql postgres sqlite ssl zlib luajit libressl"
REQUIRED_USE="${LUA_REQUIRED_USE}"

DEPEND="net-im/jabber-base
		${LUA_DEPS}
		dev-lua/LuaBitOp
		>=net-dns/libidn-1.1:=
		!libressl? ( dev-libs/openssl:0 ) libressl? ( dev-libs/libressl:= )"
RDEPEND="${DEPEND}
		>=dev-lua/luaexpat-1.3.0
		dev-lua/luafilesystem
		ipv6? ( >=dev-lua/luasocket-3 )
		!ipv6? ( dev-lua/luasocket )
		libevent? ( >=dev-lua/luaevent-0.4.3 )
		mysql? ( dev-lua/luadbi[mysql] )
		postgres? ( dev-lua/luadbi[postgres] )
		sqlite? ( dev-lua/luadbi[sqlite] )
		ssl? ( dev-lua/luasec )
		zlib? ( dev-lua/lua-zlib )"

JABBER_ETC="${EPREFIX}/etc/jabber"
JABBER_SPOOL="${EPREFIX}/var/spool/jabber"

src_prepare() {
	eapply "${FILESDIR}/${PN}-0.10.0-cfg.lua.patch"
	sed -i -e "s!MODULES = \$(DESTDIR)\$(PREFIX)/lib/!MODULES = \$(DESTDIR)\$(PREFIX)/$(get_libdir)/!"\
		-e "s!SOURCE = \$(DESTDIR)\$(PREFIX)/lib/!SOURCE = \$(DESTDIR)\$(PREFIX)/$(get_libdir)/!"\
		-e "s!INSTALLEDSOURCE = \$(PREFIX)/lib/!INSTALLEDSOURCE = \$(PREFIX)/$(get_libdir)/!"\
		-e "s!INSTALLEDMODULES = \$(PREFIX)/lib/!INSTALLEDMODULES = \$(PREFIX)/$(get_libdir)/!"\
		Makefile || die
	default
}

src_configure() {
	# the configure script is handcrafted (and yells at unknown options)
	# hence do not use 'econf'
	append-cflags -D_GNU_SOURCE
	use elibc_musl && append-cflags -DWITHOUT_MALLINFO
	./configure \
		--ostype=linux \
		--prefix="${EPREFIX}/usr" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--sysconfdir="${JABBER_ETC}" \
		--datadir="${JABBER_SPOOL}" \
		--with-lua-include="${EPREFIX}/usr/include" \
		--with-lua-lib="${EPREFIX}/usr/$(get_libdir)/lua" \
		--runwith=lua"$(usev luajit)" \
		--cflags="${CFLAGS} -Wall -fPIC" \
		--ldflags="${LDFLAGS} -shared" \
		--c-compiler="$(tc-getCC)" \
		--linker="$(tc-getCC)" || die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install
	systemd_dounit "${FILESDIR}/${PN}".service
	systemd_newtmpfilesd "${FILESDIR}/${PN}".tmpfilesd "${PN}".conf
	newinitd "${FILESDIR}/${PN}".initd-r2 ${PN}
	keepdir "${JABBER_SPOOL}"
}

src_test() {
	cd tests || die
	./run_tests.sh || die
}
