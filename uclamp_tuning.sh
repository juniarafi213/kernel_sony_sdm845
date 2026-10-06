#!/system/bin/sh

#Uclamp tuning
sysctl -w kernel.sched_util_clamp_min_rt_default=96
sysctl -w kernel.sched_util_clamp_min=128

#top-app
echo max > /dev/cpuset/top-app/uclamp.max
echo 20  > /dev/cpuset/top-app/uclamp.min
echo 1   > /dev/cpuset/top-app/uclamp.boosted
echo 1   > /dev/cpuset/top-app/uclamp.latency_sensitive

#foreground
echo 50 > /dev/cpuset/foreground/uclamp.max
echo 20 > /dev/cpuset/foreground/uclamp.min
echo 0  > /dev/cpuset/foreground/uclamp.boosted
echo 0  > /dev/cpuset/foreground/uclamp.latency_sensitive

#background
echo max > /dev/cpuset/background/uclamp.max
echo 20  > /dev/cpuset/background/uclamp.min
echo 0   > /dev/cpuset/background/uclamp.boosted
echo 0   > /dev/cpuset/background/uclamp.latency_sensitive

#system-background
echo 50 > /dev/cpuset/system-background/uclamp.max
echo 10 > /dev/cpuset/system-background/uclamp.min
echo 0  > /dev/cpuset/system-background/uclamp.boosted
echo 0  > /dev/cpuset/system-background/uclamp.latency_sensitive

# Virtual Memory (VM) & Memory Management Tuning
# Swappiness: 100 is optimal for 4GB RAM + 4GB ZRAM (ZSTD)
sysctl -w vm.swappiness=100

# Page cluster: 0 disables unnecessary sequential read-ahead on ZRAM
sysctl -w vm.page-cluster=0

# VFS cache pressure: preserve dentry and inode cache longer in RAM
sysctl -w vm.vfs_cache_pressure=70

# Extra free kbytes: increase buffer between min and low watermarks to prevent direct reclaim stutters
sysctl -w vm.extra_free_kbytes=51200

# Dirty ratio: start flushing dirty pages to storage earlier in the background
sysctl -w vm.dirty_ratio=15
sysctl -w vm.dirty_background_ratio=5

# Compaction: prevent wasting CPU cycles attempting to compact unevictable pages
sysctl -w vm.compact_unevictable_allowed=0
