################################################################################
#
# Transmogrify
#
################################################################################

ifeq (y , $(BR2_PACKAGE_TRANSMOGRIFY_STABLE))
TRANSMOGRIFY_VERSION = master
else
TRANSMOGRIFY_VERSION = develop
endif


ifeq (y , $(BR2_PACKAGE_TRANSMOGRIFY_SRC))
TRANSMOGRIFY_SITE = "https://github.com/truschival/Transmogrify.git"
TRANSMOGRIFY_SITE_METHOD = git
TRANSMOGRIFY_INSTALL_STAGING = YES
$(eval $(cmake-gen-bin-pkg))

else #Binary only distribution
TRANSMOGRIFY_SOURCE = transmogrify-$(TRANSMOGRIFY_VERSION)_$(BR2_ARCH).tar.gz
TRANSMOGRIFY_SITE =  "https://s3-sa-east-1.amazonaws.com/truschival/buildroot-pkgs"
TRANSMOGRIFY_SITE_METHOD = wget
$(eval $(bin-only-pkg))

endif
