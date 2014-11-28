# Copyright 2014 Oleg Shevelev
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

EGIT_REPO_URI="http://github.com/DeNA/HandlerSocket-Plugin-for-MySQL.git"
inherit autotools git-2

DESCRIPTION="HandlerSocket Plugin for MySQL"
HOMEPAGE="http://github.com/DeNA/HandlerSocket-Plugin-for-MySQL"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="virtual/mysql"
RDEPEND="${DEPEND}"

src_prepare() {
                MYSQL_V="$(best_version "dev-db/mysql")"
                MYSQL_V=${MYSQL_V##*/}

                patch -p0 < ${FILESDIR}/gentoo.patch
                patch -p0 < ${FILESDIR}/gcc.patch

                #eautoreconf

                DISTDIR="${T}/distdir"
                mkdir ${DISTDIR}

                einfo "Fetching sources of $MYSQL_V"
                echo "ebuild /usr/portage/dev-db/mysql/${MYSQL_V}.ebuild prepare"
                ebuild /usr/portage/dev-db/mysql/${MYSQL_V}.ebuild prepare
}

src_configure() {
        ./autogen.sh
        local myconf=""
        myconf="${myconf} --with-mysql-source=/var/tmp/portage/dev-db/${MYSQL_V}/work/mysql"
        myconf="${myconf} --with-mysql-plugindir=$(/usr/bin/mysql_config --plugindir)"
        myconf="${myconf} --with-mysql-bindir=/usr/bin/"
        econf ${myconf} || die "econf failed"
}

src_compile() {
        cd ${S}
        make
}

src_install() {
        emake DESTDIR="${D}" install || die "emake install failed"
        ebuild /usr/portage/dev-db/mysql/${MYSQL_V}.ebuild clean
        dodoc "${S}"/docs-en/* || die "dodoc failed"
}

pkg_postinst() {
        einfo "Using Handlersocket

Append configuration options for handlersocket to my.cnf.

  [mysqld]
  loose_handlersocket_port = 9998
    # the port number to bind to (for read requests)
  loose_handlersocket_port_wr = 9999
    # the port number to bind to (for write requests)
  loose_handlersocket_threads = 16
    # the number of worker threads (for read requests)
  loose_handlersocket_threads_wr = 1
    # the number of worker threads (for write requests)
  open_files_limit = 65535
    # to allow handlersocket accept many concurrent
    # connections, make open_files_limit as large as
    # possible.
  plugin-load=handlersocket.so

Log in to mysql as root, and execute the following query.

  mysql> install plugin handlersocket soname 'handlersocket.so';

If handlersocket.so is successfully installed, it starts
accepting connections on port 9998 and 9999. Running
'show processlist' should show handlersocket worker threads.
Check installation.en.txt for more options."
}
