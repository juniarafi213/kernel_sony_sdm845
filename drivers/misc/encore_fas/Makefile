# SPDX-License-Identifier: GPL-2.0-only
obj-$(CONFIG_ENCORE_FAS) += encore_fas.o
encore_fas-y := encore_fas_main.o \
                encore_fas_ctx.o \
                encore_fas_evq.o \
                encore_fas_time.o

ccflags-y += -I$(srctree)/$(src)/include -I$(src)/include

# Probe the kernel headers. A vendor kernel can backport an API, so the
# headers are more exact than LINUX_VERSION_CODE.
fas_uprobes_h := $(srctree)/include/linux/uprobes.h
fas_hrtimer_h := $(srctree)/include/linux/hrtimer.h

ifneq ($(shell grep -qs uprobe_unregister_nosync $(fas_uprobes_h) && echo y),)
ifneq ($(shell grep -qs '__u64 \*' $(fas_uprobes_h) && echo y),)
ccflags-y += -DFAS_UPROBE_API=3
else
ccflags-y += -DFAS_UPROBE_API=2
endif
else
ccflags-y += -DFAS_UPROBE_API=1
endif

ifneq ($(shell grep -qs hrtimer_setup $(fas_hrtimer_h) && echo y),)
ccflags-y += -DFAS_HAVE_HRTIMER_SETUP
endif

# The timer modes moved to hrtimer_types.h in v6.10.
ifneq ($(shell cat $(srctree)/include/linux/hrtimer*.h 2>/dev/null | grep -qs HRTIMER_MODE_REL_PINNED_SOFT && echo y),)
ccflags-y += -DFAS_HAVE_HRTIMER_SOFT
endif

ccflags-y += -DFAS_VERSION=1 -DFAS_BRANCH=\"main\"
