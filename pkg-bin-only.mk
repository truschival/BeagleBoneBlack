################################################################################
# Packages distributed as binary tarball in staging and target
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name, including a HOST_ prefix
#             for host packages
#  argument 3 is the uppercase package name, without the HOST_ prefix
#             for host packages
#  argument 4 is the type (target or host)
################################################################################

define inner-bin-only-package

$(2)_SRCDIR	= $$($(2)_DIR)/$$($(2)_SUBDIR)
$(2)_BUILDDIR	= $$($(2)_SRCDIR)

$(2)_EXTRACT_CMDS = (cd $(BASE_DIR) && tar -xf $(DL_DIR)/$$($(2)_SOURCE))

define $(2)_STAMP_ALL
	$(Q)$(call MESSAGE,"---------- Installing Binary Package $(1) ----------") ;
	$(Q)$(call MESSAGE,"Stamping Patched") ;
	$(Q)touch $$($(2)_BUILDDIR)/.stamp_patched
	$(Q)$(call MESSAGE,"Stamping Configure") ;
	$(Q)touch $$($(2)_BUILDDIR)/.stamp_configured
	$(Q)$(call MESSAGE,"Stamping Build") ;
	$(Q)touch $$($(2)_BUILDDIR)/.stamp_built
	$(Q)$(call MESSAGE,"Stamping Staging Installed") ;
	$(Q)touch $$($(2)_BUILDDIR)/.stamp_staging_installed
	$(Q)$(call MESSAGE,"Stamping Target Installed") ;
	$(Q)touch $$($(2)_BUILDDIR)/.stamp_target_installed
	$(Q)$(call MESSAGE,"---------- Installiert Binary Package $(1) ----------") ;
endef

# After Extracting just stamp to avoid further steps
$(2)_POST_EXTRACT_HOOKS += $(2)_STAMP_ALL

# Call the generic package infrastructure to generate the necessary
# make targets
$(call inner-generic-package,$(1),$(2),$(3),$(4))

endef #inner-bin-only-package

################################################################################
# Bin-only package
################################################################################

bin-only-pkg = $(call inner-bin-only-package,$(pkgname),$(call UPPERCASE,$(pkgname)),$(call UPPERCASE,$(pkgname)),target)
