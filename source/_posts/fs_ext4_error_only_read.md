---
title: ext4文件系统变为只读
categories: 文件系统
tags:
  - ext4
abbrlink: 31493
date: 2018-04-04 12:07:24
---

```
[ 7965.955384] EXT4-fs error (device mmcblk0p7): ext4_mb_generate_buddy:758: group 3, block bitmap and bg descriptor inconsistent: 1901 vs 1900 free clusters
[ 7965.963826] EXT4-fs (mmcblk0p7): Remounting filesystem read-only
[ 7965.975652] EXT4-fs (mmcblk0p7): ext4_writepages: jbd2_start: 2147483644 pages, ino 6032; err -30
```

<!--more-->

ext4文件系统bug，在linux4.6.7中以修复。

```
commit d123a55f85f5116d686dac80c768ee5c34ec8e06
Author: Vegard Nossum <vegard.nossum@oracle.com>
Date:   Thu Jul 14 23:21:35 2016 -0400

    ext4: short-cut orphan cleanup on error

    commit c65d5c6c81a1f27dec5f627f67840726fcd146de upstream.

    If we encounter a filesystem error during orphan cleanup, we should stop.
    Otherwise, we may end up in an infinite loop where the same inode is
    processed again and again.

        EXT4-fs (loop0): warning: checktime reached, running e2fsck is recommended
        EXT4-fs error (device loop0): ext4_mb_generate_buddy:758: group 2, block bitmap and bg descriptor inconsistent: 6117 vs 0 free clusters
        Aborting journal on device loop0-8.
        EXT4-fs (loop0): Remounting filesystem read-only
        EXT4-fs error (device loop0) in ext4_free_blocks:4895: Journal has aborted
        EXT4-fs error (device loop0) in ext4_do_update_inode:4893: Journal has aborted
        EXT4-fs error (device loop0) in ext4_do_update_inode:4893: Journal has aborted
        EXT4-fs error (device loop0) in ext4_ext_remove_space:3068: IO failure
        EXT4-fs error (device loop0) in ext4_ext_truncate:4667: Journal has aborted
        EXT4-fs error (device loop0) in ext4_orphan_del:2927: Journal has aborted
        EXT4-fs error (device loop0) in ext4_do_update_inode:4893: Journal has aborted
        EXT4-fs (loop0): Inode 16 (00000000618192a0): orphan list check failed!
        [...]
        EXT4-fs (loop0): Inode 16 (0000000061819748): orphan list check failed!
        [...]
        EXT4-fs (loop0): Inode 16 (0000000061819bf0): orphan list check failed!
        [...]

    See-also: c9eb13a9105 ("ext4: fix hang when processing corrupted orphaned inode list")
    Cc: Jan Kara <jack@suse.cz>
    Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
    Signed-off-by: Theodore Ts'o <tytso@mit.edu>
    Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 089821b..7fca76b 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -2277,6 +2277,16 @@ static void ext4_orphan_cleanup(struct super_block *sb,
        while (es->s_last_orphan) {
                struct inode *inode;

+               /*
+                * We may have encountered an error during cleanup; if
+                * so, skip the rest.
+                */
+               if (EXT4_SB(sb)->s_mount_state & EXT4_ERROR_FS) {
+                       jbd_debug(1, "Skipping orphan recovery on fs with errors.\n");
+                       es->s_last_orphan = 0;
+                       break;
+               }
+
                inode = ext4_orphan_get(sb, le32_to_cpu(es->s_last_orphan));
                if (IS_ERR(inode)) {
                        es->s_last_orphan = 0;
```

[linux v4.x ChangeLog-4.6.7](https://mirrors.edge.kernel.org/pub/linux/kernel/v4.x/ChangeLog-4.6.7)

## 产生的原因：


