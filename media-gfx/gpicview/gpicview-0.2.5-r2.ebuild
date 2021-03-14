# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg-utils

DESCRIPTION="A Simple and Fast Image Viewer for X"
HOMEPAGE="http://lxde.sourceforge.net/gpicview"
SRC_URI="mirror://sourceforge/lxde/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ppc ~x86"
IUSE=""

RDEPEND="virtual/jpeg:0
	x11-libs/gtk+:3"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/gpicview-0.2.5-gtk3_no_x.diff"
	"${FILESDIR}/gpicview-0.2.5-gif_animation.diff"
	"${FILESDIR}/Fix-displaying-images-with-GTK3.patch"
)

src_configure() {
	econf --enable-gtk3
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
