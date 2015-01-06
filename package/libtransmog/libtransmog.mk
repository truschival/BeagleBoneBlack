################################################################################
#
# Libransmog
#
################################################################################

LIBTRANSMOG_VERSION = $(BR2_PACKAGE_LIBTRANSMOG_VERSION)

ifeq (y , $(BR2_PACKAGE_LIBTRANSMOG_SRC))
LIBTRANSMOG_SITE = "https://github.com/truschival/libtransmogrify.git"
LIBTRANSMOG_SITE_METHOD = git
LIBTRANSMOG_INSTALL_STAGING = YES
LIBTRANSMOG_CONF_OPTS = -DMAGIC_MOJO=$(BR2_PACKAGE_LIBTRANSMOG_MAGIC_MOJO)

$(eval $(cmake-gen-bin-pkg))

else #Binary only distribution
LIBTRANSMOG_SOURCE = libtransmog-$(LIBTRANSMOG_VERSION)_$(BR2_ARCH).tar.gz
LIBTRANSMOG_SITE =  "https://s3-sa-east-1.amazonaws.com/truschival/buildroot-pkgs"
LIBTRANSMOG_SITE_METHOD = wget
$(eval $(bin-only-pkg))

endif
