# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2-utils xdg-utils

DESCRIPTION="A Simple and Fast Image Viewer for X"
HOMEPAGE="http://lxde.sourceforge.net/gpicview"
SRC_URI="mirror://sourceforge/lxde/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ppc x86 ~x86-linux"
IUSE="gtk3"

RDEPEND="virtual/jpeg:0
	!gtk3? ( >=x11-libs/gtk+-2.6:2 )
	gtk3? ( >=x11-libs/gtk+-3.10:3 )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig"

src_configure() {
	if use gtk3; then
		econf --enable-gtk3
	else
		econf
	fi
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
