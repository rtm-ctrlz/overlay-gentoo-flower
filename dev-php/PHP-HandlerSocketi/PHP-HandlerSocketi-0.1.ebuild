# Copyright 2014 Oleg Shevelev
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PHP_EXT_NAME="handlersocketi"
PHP_EXT_SKIP_PHPIZE="no"
USE_PHP="php5-5"

EGIT_REPO_URI="https://github.com/kjdev/php-ext-handlersocketi.git"
inherit php-ext-source-r2 git-2

DESCRIPTION="HandlerSocket PHP Client for MySQL"
HOMEPAGE="https://github.com/kjdev/php-ext-handlersocketi"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="native"

DEPEND="dev-lang/php"
RDEPEND="${DEPEND}"

src_unpack() {
    git-2_src_unpack

    for slot in $(php_get_slots); do
        cp -r "${S}" "${WORKDIR}/${slot}"
        mkdir ${WORKDIR}/${slot}/modules
    done
}

src_install() {
    for slot in $(php_get_slots); do
        php_init_slot_env ${slot}
        insinto "${EXT_DIR}"
        newins "${WORKDIR}/${slot}/modules/${PHP_EXT_NAME}.so" "${PHP_EXT_NAME}.so"
    done
    php-ext-source-r2_createinifiles
}

pkg_postinst() {
        einfo "
        PHP HandlerSocketi is Installed.

        Please run /etc/init.d/php-fpm restart
        "
}
