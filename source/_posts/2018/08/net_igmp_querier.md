---
layout: "post"
title: IGMP snooping 查询器
date: "2018-08-11 14:23"
---



<!--more-->


## 实现

```C
uint16_t cksum(void *buf, size_t len)
{
    uint32_t cksum = 0;
    int i;
    int short_len = len / 2;

    for (i = 0; i < short_len; i++) {
        cksum += ((uint16_t*)buf)[i];
    }
    if (len % 2) {
        cksum += ((uint8_t*)buf)[len - 1];
    }
    cksum = (cksum >> 16) + (cksum & 0xFFFF);
    cksum = cksum + (cksum >> 16);

    return (~cksum & 0xFFFF);
}
```

``` C
   struct igmp igmp;
   struct in_addr mgroup, allhosts;
   struct sockaddr_in dst;

   /* Create socket */
   sockfd = socket(PF_INET, SOCK_RAW, IPPROTO_IGMP);

   /* Multicast groups */
   mgroup.s_addr = inet_addr("0.0.0.0");
   if (mgroup.s_addr == INADDR_NONE) {
        printf("Invalid multicast group '0.0.0.0'");
        goto fail;
    }
    allhosts.s_addr = inet_addr("224.0.0.1");
    if (allhosts.s_addr == INADDR_NONE) {
        printf("Invalid multicast group '224.0.0.1'");
        goto fail;
    }

    /* IGMPv1 query */
    igmp.igmp_type = IGMP_MEMBERSHIP_QUERY;
    igmp.igmp_code = 0;
    igmp.igmp_cksum = 0;
    igmp.igmp_group = mgroup;
    igmp.igmp_cksum = cksum(&igmp, sizeof(igmp));

    /* Destination */
    dst.sin_family = AF_INET;
    dst.sin_port = htons(0);
    dst.sin_addr = allhosts;

    /* Transmit loop */
    while (1) {
        if (sendto(sockfd, &igmp, sizeof(igmp), 0, (struct sockaddr*)&dst, sizeof(dst)) == -1) {
            printf("Could not send IGMP query: %s", strerror(errno));
        }
        sleep(options->interval);
    }
```
