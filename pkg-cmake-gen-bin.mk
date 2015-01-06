################################################################################
# CMake package infrastructure
#
# This file implements an infrastructure that eases development of
# package .mk files for CMake packages. It should be used for all
# packages that use CMake as their build system.
#
# See the Buildroot documentation for details on the usage of this
# infrastructure
#
# In terms of implementation, this CMake infrastructure requires
# the .mk file to only specify metadata information about the
# package: name, version, download URL, etc.
#
# We still allow the package .mk file to override what the different
# steps are doing, if needed. For example, if <PKG>_BUILD_CMDS is
# already defined, it is used as the list of commands to perform to
# build the package, instead of the default CMake behaviour. The
# package can also define some post operation hooks.
#
################################################################################

################################################################################
# inner-cmake-gen-bin -- defines how the configuration, compilation and
# installation of a CMake package should be done, implements a few hooks to
# tune the build process and calls the generic package infrastructure to
# generate the necessary make targets
#
#  This package is the same as inner-cmake-package but generates a
#  tar-ball with componts of the package installed to staging and target
#  File will be created in the Download dir
#
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name, including a HOST_ prefix
#             for host packages
#  argument 3 is the uppercase package name, without the HOST_ prefix
#             for host packages
#  argument 4 is the type (target or host)
################################################################################

define inner-cmake-gen-bin

$(2)_CONF_ENV			?=
$(2)_CONF_OPTS			?=
$(2)_MAKE			?= $$(MAKE)
$(2)_MAKE_ENV			?=
$(2)_MAKE_OPTS			?=
$(2)_INSTALL_OPTS		?= install
$(2)_INSTALL_STAGING_OPTS	?= DESTDIR=$$(STAGING_DIR) install
$(2)_INSTALL_TARGET_OPTS	?= DESTDIR=$$(TARGET_DIR) install

$(2)_SRCDIR		= $$($(2)_DIR)/$$($(2)_SUBDIR)
$(2)_BUILDDIR		= $$($(2)_SRCDIR)_build

#local hacks  to generage a tar-ball
sysroot_in_staging := $(firstword $(wildcard $(O)/staging/sysroot))
ifeq ( , $(sysroot_in_staging))
$(2)_STAGING_DIR_NAME		?= staging
else
$(2)_STAGING_DIR_NAME		?= staging/sysroot
endif

$(2)_INSTALL_LOCAL_STAGING_OPTS	?= DESTDIR=$$($(2)_SRCDIR)/$$($(2)_STAGING_DIR_NAME)/ install
$(2)_TARGET_DIR_NAME		?= target
$(2)_INSTALL_LOCAL_TARGET_OPTS	?= DESTDIR=$$($(2)_SRCDIR)/$$($(2)_TARGET_DIR_NAME)/ install
# Generated tar-ball
$(2)_DEV_PKG_TAR_FILE ?= $(SRC_BIN_PRE_BUILT_DIR)/$(1)-$$($(2)_VERSION)_$(BR2_ARCH).tar.gz

# Create package-local staging + target dir install the package and tar it
define $(2)_CREATE_BIN_PKG_TAR
	$(Q)$(call MESSAGE,"--- Creating Binary Package: $(sysroot_in_staging)  ---") ;


	$(Q)mkdir -p $(SRC_BIN_PRE_BUILT_DIR)
	$(Q)$(call MESSAGE,"--- Creating Binary Package: $$($(2)_DEV_PKG_TAR_FILE) ---") ;
	$(Q)mkdir -p  $$($(2)_SRCDIR)/$$($(2)_STAGING_DIR_NAME)
	$(Q)$$(TARGET_MAKE_ENV) $$($$(PKG)_MAKE_ENV) $$($$(PKG)_MAKE) $$($$(PKG)_MAKE_OPTS) $$($$(PKG)_INSTALL_LOCAL_STAGING_OPTS) -C $$($$(PKG)_BUILDDIR)
	$(Q)mkdir -p  $$($(2)_SRCDIR)/$$($(2)_TARGET_DIR_NAME)
	$(Q)$$(TARGET_MAKE_ENV) $$($$(PKG)_MAKE_ENV) $$($$(PKG)_MAKE) $$($$(PKG)_MAKE_OPTS) $$($$(PKG)_INSTALL_LOCAL_TARGET_OPTS) -C $$($$(PKG)_BUILDDIR)
	$(Q)(cd $$($(2)_SRCDIR) && tar -cvzf $$($(2)_DEV_PKG_TAR_FILE)  $$($(2)_TARGET_DIR_NAME) $$($(2)_STAGING_DIR_NAME)	)
endef

#only after regular staging install works
$(2)_POST_INSTALL_STAGING_HOOKS += $(2)_CREATE_BIN_PKG_TAR

#
# Configure step. Only define it if not already defined by the package
# .mk file. And take care of the differences between host and target
# packages.
#
ifndef $(2)_CONFIGURE_CMDS
ifeq ($(4),target)

# Configure package for target
define $(2)_CONFIGURE_CMDS
	(mkdir -p $$($$(PKG)_BUILDDIR) && \
	cd $$($$(PKG)_BUILDDIR) && \
	rm -f CMakeCache.txt && \
	PATH=$$(BR_PATH) \
	$$($$(PKG)_CONF_ENV) $$(HOST_DIR)/usr/bin/cmake $$($$(PKG)_SRCDIR) \
		-DCMAKE_TOOLCHAIN_FILE="$$(HOST_DIR)/usr/share/buildroot/toolchainfile.cmake" \
		-DCMAKE_BUILD_TYPE=$$(if $$(BR2_ENABLE_DEBUG),Debug,Release) \
		-DCMAKE_INSTALL_PREFIX="/usr" \
		-DCMAKE_COLOR_MAKEFILE=OFF \
		-DBUILD_DOC=OFF \
		-DBUILD_DOCS=OFF \
		-DBUILD_EXAMPLE=OFF \
		-DBUILD_EXAMPLES=OFF \
		-DBUILD_TEST=OFF \
		-DBUILD_TESTS=OFF \
		-DBUILD_TESTING=OFF \
		-DBUILD_SHARED_LIBS=$$(if $$(BR2_PREFER_STATIC_LIB),OFF,ON) \
		-DUSE_CCACHE=$$(if $$(BR2_CCACHE),ON,OFF) \
		$$($$(PKG)_CONF_OPTS) \
	)
endef

endif
endif

# This must be repeated from inner-generic-package, otherwise we only get
# host-cmake in _DEPENDENCIES because of the following line
ifeq ($(4),host)
$(2)_DEPENDENCIES ?= $$(filter-out host-toolchain $(1),$$(patsubst host-host-%,host-%,$$(addprefix host-,$$($(3)_DEPENDENCIES))))
endif

$(2)_DEPENDENCIES += host-cmake

#
# Build step. Only define it if not already defined by the package .mk
# file.
#
ifndef $(2)_BUILD_CMDS
ifeq ($(4),target)
define $(2)_BUILD_CMDS
	$$(TARGET_MAKE_ENV) $$($$(PKG)_MAKE_ENV) $$($$(PKG)_MAKE) $$($$(PKG)_MAKE_OPTS) -C $$($$(PKG)_BUILDDIR)
endef
else
define $(2)_BUILD_CMDS
	$$(HOST_MAKE_ENV) $$($$(PKG)_MAKE_ENV) $$($$(PKG)_MAKE) $$($$(PKG)_MAKE_OPTS) -C $$($$(PKG)_BUILDDIR)
endef
endif
endif

#
# Host installation step. Only define it if not already defined by the
# package .mk file.
#
ifndef $(2)_INSTALL_CMDS
define $(2)_INSTALL_CMDS
	$$(HOST_MAKE_ENV) $$($$(PKG)_MAKE_ENV) $$($$(PKG)_MAKE) $$($$(PKG)_MAKE_OPTS) $$($$(PKG)_INSTALL_OPTS) -C $$($$(PKG)_BUILDDIR)
endef
endif

#
# Staging installation step. Only define it if not already defined by
# the package .mk file.
#
ifndef $(2)_INSTALL_STAGING_CMDS
define $(2)_INSTALL_STAGING_CMDS
	$$(TARGET_MAKE_ENV) $$($$(PKG)_MAKE_ENV) $$($$(PKG)_MAKE) $$($$(PKG)_MAKE_OPTS) $$($$(PKG)_INSTALL_STAGING_OPTS) -C $$($$(PKG)_BUILDDIR)
endef
endif

#
# Target installation step. Only define it if not already defined by
# the package .mk file.
#
ifndef $(2)_INSTALL_TARGET_CMDS
define $(2)_INSTALL_TARGET_CMDS
	$$(TARGET_MAKE_ENV) $$($$(PKG)_MAKE_ENV) $$($$(PKG)_MAKE) $$($$(PKG)_MAKE_OPTS) $$($$(PKG)_INSTALL_TARGET_OPTS) -C $$($$(PKG)_BUILDDIR)
endef
endif

# Call the generic package infrastructure to generate the necessary
# make targets
$(call inner-generic-package,$(1),$(2),$(3),$(4))

endef

################################################################################
# cmake-package -- the target generator macro for CMake packages
################################################################################

cmake-gen-bin-pkg = $(call inner-cmake-gen-bin,$(pkgname),$(call UPPERCASE,$(pkgname)),$(call UPPERCASE,$(pkgname)),target)
