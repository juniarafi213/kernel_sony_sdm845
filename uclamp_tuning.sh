#!/system/bin/sh

# ==============================================================================
# SchedTune, UCLAMP & Memory Optimizer for Sony SDM845 (Tama)
# Tailored for CASS + SchedTune / UCLAMP + BORE on Android 10 (QASSA) & Android 11+
# ==============================================================================

# 1. UCLAMP tuning (if present on Android 11+)
if [ -f "/dev/cpuset/top-app/uclamp.min" ]; then
    sysctl -w kernel.sched_util_clamp_min_rt_default=96 2>/dev/null
    sysctl -w kernel.sched_util_clamp_min=128 2>/dev/null

    echo max > /dev/cpuset/top-app/uclamp.max 2>/dev/null
    echo 20  > /dev/cpuset/top-app/uclamp.min 2>/dev/null
    echo 1   > /dev/cpuset/top-app/uclamp.boosted 2>/dev/null
    echo 1   > /dev/cpuset/top-app/uclamp.latency_sensitive 2>/dev/null

    echo 50 > /dev/cpuset/foreground/uclamp.max 2>/dev/null
    echo 20 > /dev/cpuset/foreground/uclamp.min 2>/dev/null
    echo 0  > /dev/cpuset/foreground/uclamp.boosted 2>/dev/null
    echo 0  > /dev/cpuset/foreground/uclamp.latency_sensitive 2>/dev/null

    echo max > /dev/cpuset/background/uclamp.max 2>/dev/null
    echo 20  > /dev/cpuset/background/uclamp.min 2>/dev/null
    echo 0   > /dev/cpuset/background/uclamp.boosted 2>/dev/null
    echo 0   > /dev/cpuset/background/uclamp.latency_sensitive 2>/dev/null

    echo 50 > /dev/cpuset/system-background/uclamp.max 2>/dev/null
    echo 10 > /dev/cpuset/system-background/uclamp.min 2>/dev/null
    echo 0  > /dev/cpuset/system-background/uclamp.boosted 2>/dev/null
    echo 0  > /dev/cpuset/system-background/uclamp.latency_sensitive 2>/dev/null
fi

# 2. Native SchedTune tuning (Android 10 QASSA / CASS / EAS)
if [ -d "/dev/stune/top-app" ]; then
    echo 20 > /dev/stune/top-app/schedtune.boost 2>/dev/null
    echo 1  > /dev/stune/top-app/schedtune.prefer_idle 2>/dev/null
    echo 1  > /dev/stune/top-app/schedtune.sched_boost_enabled 2>/dev/null
    echo 1  > /dev/stune/top-app/schedtune.colocate 2>/dev/null

    echo 0  > /dev/stune/foreground/schedtune.boost 2>/dev/null
    echo 0  > /dev/stune/foreground/schedtune.prefer_idle 2>/dev/null

    echo 0  > /dev/stune/background/schedtune.boost 2>/dev/null
    echo 0  > /dev/stune/background/schedtune.prefer_idle 2>/dev/null

    echo 0  > /dev/stune/system-background/schedtune.boost 2>/dev/null
    echo 0  > /dev/stune/system-background/schedtune.prefer_idle 2>/dev/null
fi

# 3. EAS Migration & BORE tuning (Faster ramp to Big Cores, eliminate micro-stutter)
if [ -f "/proc/sys/kernel/sched_upmigrate" ]; then
    echo 85 > /proc/sys/kernel/sched_upmigrate 2>/dev/null
    echo 70 > /proc/sys/kernel/sched_downmigrate 2>/dev/null
    echo 95 > /proc/sys/kernel/sched_group_upmigrate 2>/dev/null
    echo 85 > /proc/sys/kernel/sched_group_downmigrate 2>/dev/null
fi
echo 1 > /proc/sys/kernel/sched_bore 2>/dev/null
echo 1280 > /proc/sys/kernel/sched_burst_penalty_scale 2>/dev/null

# 4. CPUSET Core Pinning
echo 0-2 > /dev/cpuset/background/cpus 2>/dev/null
echo 0-2 > /dev/cpuset/system-background/cpus 2>/dev/null
echo 0-7 > /dev/cpuset/top-app/cpus 2>/dev/null
echo 0-7 > /dev/cpuset/foreground/cpus 2>/dev/null

# 5. Virtual Memory (VM) & ZRAM Memory Management Tuning
# Swappiness: 100 for 4GB RAM + 3.5GB ZRAM (ZSTD)
sysctl -w vm.swappiness=100 2>/dev/null

# Page cluster: 0 disables unnecessary sequential read-ahead on ZRAM
sysctl -w vm.page-cluster=0 2>/dev/null

# VFS cache pressure: preserve dentry and inode cache longer in RAM
sysctl -w vm.vfs_cache_pressure=70 2>/dev/null

# Extra free kbytes: prevent direct reclaim stutters
sysctl -w vm.extra_free_kbytes=51200 2>/dev/null

# Dirty ratio: start flushing dirty pages to storage earlier in the background
sysctl -w vm.dirty_ratio=15 2>/dev/null
sysctl -w vm.dirty_background_ratio=5 2>/dev/null

# Compaction: prevent wasting CPU cycles attempting to compact unevictable pages
sysctl -w vm.compact_unevictable_allowed=0 2>/dev/null
