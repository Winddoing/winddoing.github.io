---
layout: post
title: wpa_supplicant源码分析--conf配置文件
date: '2018-11-28 16:00'
tags:
  - wifi
categories:
  - 网络
  - wifi
abbrlink: 50085
---

解析wpa_supplicant的配置文件，一般叫做 `wpa_supplicant.conf`

在wpa_supplicant的源码中都有配置文件的示例[wpa_supplicant.conf](http://w1.fi/cgit/hostap/plain/wpa_supplicant/wpa_supplicant.conf)

<!--more-->

## wpa_supplicant.conf

当前项目中使用到的一个配置文件

```
ctrl_interface=/var/run/sockets
driver_param=use_p2p_group_interface=1p2p_device=1
update_config=1
device_name=V_9ca2
device_type=10-0050F204-5
config_methods=virtual_push_button physical_display keypad
p2p_go_intent=15
p2p_ssid_postfix=-V_9ca2
persistent_reconnect=1

network={
  ssid="D-H-V_9ca2"
  bssid=ae:83:f3:b4:9c:a2
  psk="00000000"
  proto=RSN
  key_mgmt=WPA-PSK
  pairwise=CCMP
  auth_alg=OPEN
  mode=3
  disabled=2
  p2p_client_list=1a:f0:e4:87:fb:74 ac:83:f3:b3:72:24 04:e6:76:c3:37:84
}
```
> 该配置文件用于p2p


``` shell
wpa_supplicant -iwlan0 -s -Dnl80211 -O/var/run/sockets -c/etc/wifi/p2p_supplicant.conf
```
- `-D`: 指定使用的wifi驱动, nl80211 = Linux nl80211/cfg80211
- `-i`: 指定端口
- `-C`: 指定配置文件
- `-O`: 覆盖新接口的ctrl_interface参数

## 配置文件解析

以下的数据结构都是从`wpa_supplicant_8`中的源码获取.
>`8`支持建立热点(hostapd)

### 可配置参数

wpa_supplicant的所有参数都定义在struct wpa_config中

``` C
/**
 * struct wpa_config - wpa_supplicant configuration data
 *
 * This data structure is presents the per-interface (radio) configuration
 * data. In many cases, there is only one struct wpa_config instance, but if
 * more than one network interface is being controlled, one instance is used
 * for each.
 */
struct wpa_config {
	/**
	 * ssid - Head of the global network list
	 *
	 * This is the head for the list of all the configured networks.
	 * config文件中，存储所有network节点的链表
	 */
	struct wpa_ssid *ssid;

	/**
	 * pssid - Per-priority network lists (in priority order)
	 * 按照priority排列的network节点
	 */
	struct wpa_ssid **pssid;

	/**
	 * num_prio - Number of different priorities used in the pssid lists
	 *
	 * This indicates how many per-priority network lists are included in
	 * pssid.
	 */
	int num_prio;

	/**
	 * cred - Head of the credential list
	 *
	 * This is the head for the list of all the configured credentials.
	 */
	struct wpa_cred *cred;

	/**
	 * eapol_version - IEEE 802.1X/EAPOL version number
	 *
	 * wpa_supplicant is implemented based on IEEE Std 802.1X-2004 which
	 * defines EAPOL version 2. However, there are many APs that do not
	 * handle the new version number correctly (they seem to drop the
	 * frames completely). In order to make wpa_supplicant interoperate
	 * with these APs, the version number is set to 1 by default. This
	 * configuration value can be used to set it to the new version (2).
	 */
	int eapol_version;

	/**
	 * ap_scan - AP scanning/selection
	 *
	 * By default, wpa_supplicant requests driver to perform AP
	 * scanning and then uses the scan results to select a
	 * suitable AP. Another alternative is to allow the driver to
	 * take care of AP scanning and selection and use
	 * wpa_supplicant just to process EAPOL frames based on IEEE
	 * 802.11 association information from the driver.
	 *
	 * 1: wpa_supplicant initiates scanning and AP selection (default).
	 *
	 * 0: Driver takes care of scanning, AP selection, and IEEE 802.11
	 * association parameters (e.g., WPA IE generation); this mode can
	 * also be used with non-WPA drivers when using IEEE 802.1X mode;
	 * do not try to associate with APs (i.e., external program needs
	 * to control association). This mode must also be used when using
	 * wired Ethernet drivers.
	 *
	 * 2: like 0, but associate with APs using security policy and SSID
	 * (but not BSSID); this can be used, e.g., with ndiswrapper and NDIS
	 * drivers to enable operation with hidden SSIDs and optimized roaming;
	 * in this mode, the network blocks in the configuration are tried
	 * one by one until the driver reports successful association; each
	 * network block should have explicit security policy (i.e., only one
	 * option in the lists) for key_mgmt, pairwise, group, proto variables.
	 */
	int ap_scan;

	/**
	 * disable_scan_offload - Disable automatic offloading of scan requests
	 *
	 * By default, %wpa_supplicant tries to offload scanning if the driver
	 * indicates support for this (sched_scan). This configuration
	 * parameter can be used to disable this offloading mechanism.
	 */
	int disable_scan_offload;

	/**
	 * ctrl_interface - Parameters for the control interface
	 *
	 * If this is specified, %wpa_supplicant will open a control interface
	 * that is available for external programs to manage %wpa_supplicant.
	 * The meaning of this string depends on which control interface
	 * mechanism is used. For all cases, the existence of this parameter
	 * in configuration is used to determine whether the control interface
	 * is enabled.
	 *
	 * For UNIX domain sockets (default on Linux and BSD): This is a
	 * directory that will be created for UNIX domain sockets for listening
	 * to requests from external programs (CLI/GUI, etc.) for status
	 * information and configuration. The socket file will be named based
	 * on the interface name, so multiple %wpa_supplicant processes can be
	 * run at the same time if more than one interface is used.
	 * /var/run/wpa_supplicant is the recommended directory for sockets and
	 * by default, wpa_cli will use it when trying to connect with
	 * %wpa_supplicant.
	 *
	 * Access control for the control interface can be configured
	 * by setting the directory to allow only members of a group
	 * to use sockets. This way, it is possible to run
	 * %wpa_supplicant as root (since it needs to change network
	 * configuration and open raw sockets) and still allow GUI/CLI
	 * components to be run as non-root users. However, since the
	 * control interface can be used to change the network
	 * configuration, this access needs to be protected in many
	 * cases. By default, %wpa_supplicant is configured to use gid
	 * 0 (root). If you want to allow non-root users to use the
	 * control interface, add a new group and change this value to
	 * match with that group. Add users that should have control
	 * interface access to this group.
	 *
	 * When configuring both the directory and group, use following format:
	 * DIR=/var/run/wpa_supplicant GROUP=wheel
	 * DIR=/var/run/wpa_supplicant GROUP=0
	 * (group can be either group name or gid)
	 *
	 * For UDP connections (default on Windows): The value will be ignored.
	 * This variable is just used to select that the control interface is
	 * to be created. The value can be set to, e.g., udp
	 * (ctrl_interface=udp).
	 *
	 * For Windows Named Pipe: This value can be used to set the security
	 * descriptor for controlling access to the control interface. Security
	 * descriptor can be set using Security Descriptor String Format (see
	 * http://msdn.microsoft.com/library/default.asp?url=/library/en-us/secauthz/security/security_descriptor_string_format.asp).
	 * The descriptor string needs to be prefixed with SDDL=. For example,
	 * ctrl_interface=SDDL=D: would set an empty DACL (which will reject
	 * all connections).
	 */
	char *ctrl_interface;

	/**
	 * ctrl_interface_group - Control interface group (DEPRECATED)
	 *
	 * This variable is only used for backwards compatibility. Group for
	 * UNIX domain sockets should now be specified using GROUP=group in
	 * ctrl_interface variable.
	 */
	char *ctrl_interface_group;

	/**
	 * fast_reauth - EAP fast re-authentication (session resumption)
	 *
	 * By default, fast re-authentication is enabled for all EAP methods
	 * that support it. This variable can be used to disable fast
	 * re-authentication (by setting fast_reauth=0). Normally, there is no
	 * need to disable fast re-authentication.
	 */
	int fast_reauth;

	/**
	 * opensc_engine_path - Path to the OpenSSL engine for opensc
	 *
	 * This is an OpenSSL specific configuration option for loading OpenSC
	 * engine (engine_opensc.so); if %NULL, this engine is not loaded.
	 */
	char *opensc_engine_path;

	/**
	 * pkcs11_engine_path - Path to the OpenSSL engine for PKCS#11
	 *
	 * This is an OpenSSL specific configuration option for loading PKCS#11
	 * engine (engine_pkcs11.so); if %NULL, this engine is not loaded.
	 */
	char *pkcs11_engine_path;

	/**
	 * pkcs11_module_path - Path to the OpenSSL OpenSC/PKCS#11 module
	 *
	 * This is an OpenSSL specific configuration option for configuring
	 * path to OpenSC/PKCS#11 engine (opensc-pkcs11.so); if %NULL, this
	 * module is not loaded.
	 */
	char *pkcs11_module_path;

	/**
	 * pcsc_reader - PC/SC reader name prefix
	 *
	 * If not %NULL, PC/SC reader with a name that matches this prefix is
	 * initialized for SIM/USIM access. Empty string can be used to match
	 * the first available reader.
	 */
	char *pcsc_reader;

	/**
	 * pcsc_pin - PIN for USIM, GSM SIM, and smartcards
	 *
	 * This field is used to configure PIN for SIM/USIM for EAP-SIM and
	 * EAP-AKA. If left out, this will be asked through control interface.
	 */
	char *pcsc_pin;

	/**
	 * driver_param - Driver interface parameters
	 *
	 * This text string is passed to the selected driver interface with the
	 * optional struct wpa_driver_ops::set_param() handler. This can be
	 * used to configure driver specific options without having to add new
	 * driver interface functionality.
	 */
	char *driver_param;

	/**
	 * dot11RSNAConfigPMKLifetime - Maximum lifetime of a PMK
	 *
	 * dot11 MIB variable for the maximum lifetime of a PMK in the PMK
	 * cache (unit: seconds).
	 */
	unsigned int dot11RSNAConfigPMKLifetime;

	/**
	 * dot11RSNAConfigPMKReauthThreshold - PMK re-authentication threshold
	 *
	 * dot11 MIB variable for the percentage of the PMK lifetime
	 * that should expire before an IEEE 802.1X reauthentication occurs.
	 */
	unsigned int dot11RSNAConfigPMKReauthThreshold;

	/**
	 * dot11RSNAConfigSATimeout - Security association timeout
	 *
	 * dot11 MIB variable for the maximum time a security association
	 * shall take to set up (unit: seconds).
	 */
	unsigned int dot11RSNAConfigSATimeout;

	/**
	 * update_config - Is wpa_supplicant allowed to update configuration
	 *
	 * This variable control whether wpa_supplicant is allow to re-write
	 * its configuration with wpa_config_write(). If this is zero,
	 * configuration data is only changed in memory and the external data
	 * is not overriden. If this is non-zero, wpa_supplicant will update
	 * the configuration data (e.g., a file) whenever configuration is
	 * changed. This update may replace the old configuration which can
	 * remove comments from it in case of a text file configuration.
	 */
	int update_config;

	/**
	 * blobs - Configuration blobs
	 */
	struct wpa_config_blob *blobs;

	/**
	 * uuid - Universally Unique IDentifier (UUID; see RFC 4122) for WPS
	 */
	u8 uuid[16];

	/**
	 * device_name - Device Name (WPS)
	 * User-friendly description of device; up to 32 octets encoded in
	 * UTF-8
	 */
	char *device_name;

	/**
	 * manufacturer - Manufacturer (WPS)
	 * The manufacturer of the device (up to 64 ASCII characters)
	 */
	char *manufacturer;

	/**
	 * model_name - Model Name (WPS)
	 * Model of the device (up to 32 ASCII characters)
	 */
	char *model_name;

	/**
	 * model_number - Model Number (WPS)
	 * Additional device description (up to 32 ASCII characters)
	 */
	char *model_number;

	/**
	 * serial_number - Serial Number (WPS)
	 * Serial number of the device (up to 32 characters)
	 */
	char *serial_number;

	/**
	 * device_type - Primary Device Type (WPS)
	 */
	u8 device_type[WPS_DEV_TYPE_LEN];

	/**
	 * config_methods - Config Methods
	 *
	 * This is a space-separated list of supported WPS configuration
	 * methods. For example, "label virtual_display virtual_push_button
	 * keypad".
	 * Available methods: usba ethernet label display ext_nfc_token
	 * int_nfc_token nfc_interface push_button keypad
	 * virtual_display physical_display
	 * virtual_push_button physical_push_button.
	 */
	char *config_methods;

	/**
	 * os_version - OS Version (WPS)
	 * 4-octet operating system version number
	 */
	u8 os_version[4];

	/**
	 * country - Country code
	 *
	 * This is the ISO/IEC alpha2 country code for which we are operating
	 * in
	 */
	char country[2];

	/**
	 * wps_cred_processing - Credential processing
	 *
	 *   0 = process received credentials internally
	 *   1 = do not process received credentials; just pass them over
	 *	ctrl_iface to external program(s)
	 *   2 = process received credentials internally and pass them over
	 *	ctrl_iface to external program(s)
	 */
	int wps_cred_processing;

#define MAX_SEC_DEVICE_TYPES 5
	/**
	 * sec_device_types - Secondary Device Types (P2P)
	 */
	u8 sec_device_type[MAX_SEC_DEVICE_TYPES][WPS_DEV_TYPE_LEN];
	int num_sec_device_types;

	int p2p_listen_reg_class;
	int p2p_listen_channel;
	int p2p_oper_reg_class;
	int p2p_oper_channel;
	int p2p_go_intent;
	char *p2p_ssid_postfix;
	int persistent_reconnect;
	int p2p_intra_bss;
	unsigned int num_p2p_pref_chan;
	struct p2p_channel *p2p_pref_chan;
	int p2p_ignore_shared_freq;

	struct wpabuf *wps_vendor_ext_m1;

#define MAX_WPS_VENDOR_EXT 10
	/**
	 * wps_vendor_ext - Vendor extension attributes in WPS
	 */
	struct wpabuf *wps_vendor_ext[MAX_WPS_VENDOR_EXT];

	/**
	 * p2p_group_idle - Maximum idle time in seconds for P2P group
	 *
	 * This value controls how long a P2P group is maintained after there
	 * is no other members in the group. As a GO, this means no associated
	 * stations in the group. As a P2P client, this means no GO seen in
	 * scan results. The maximum idle time is specified in seconds with 0
	 * indicating no time limit, i.e., the P2P group remains in active
	 * state indefinitely until explicitly removed. As a P2P client, the
	 * maximum idle time of P2P_MAX_CLIENT_IDLE seconds is enforced, i.e.,
	 * this parameter is mainly meant for GO use and for P2P client, it can
	 * only be used to reduce the default timeout to smaller value. A
	 * special value -1 can be used to configure immediate removal of the
	 * group for P2P client role on any disconnection after the data
	 * connection has been established.
	 */
	int p2p_group_idle;

	/**
	 * bss_max_count - Maximum number of BSS entries to keep in memory
	 */
	unsigned int bss_max_count;

	/**
	 * bss_expiration_age - BSS entry age after which it can be expired
	 *
	 * This value controls the time in seconds after which a BSS entry
	 * gets removed if it has not been updated or is not in use.
	 */
	unsigned int bss_expiration_age;

	/**
	 * bss_expiration_scan_count - Expire BSS after number of scans
	 *
	 * If the BSS entry has not been seen in this many scans, it will be
	 * removed. A value of 1 means that entry is removed after the first
	 * scan in which the BSSID is not seen. Larger values can be used
	 * to avoid BSS entries disappearing if they are not visible in
	 * every scan (e.g., low signal quality or interference).
	 */
	unsigned int bss_expiration_scan_count;

	/**
	 * filter_ssids - SSID-based scan result filtering
	 *
	 *   0 = do not filter scan results
	 *   1 = only include configured SSIDs in scan results/BSS table
	 */
	int filter_ssids;

	/**
	 * filter_rssi - RSSI-based scan result filtering
	 *
	 * 0 = do not filter scan results
	 * -n = filter scan results below -n dBm
	 */
	int filter_rssi;

	/**
	 * max_num_sta - Maximum number of STAs in an AP/P2P GO
	 */
	unsigned int max_num_sta;

	/**
	 * freq_list - Array of allowed scan frequencies or %NULL for all
	 *
	 * This is an optional zero-terminated array of frequencies in
	 * megahertz (MHz) to allow for narrowing scanning range.
	 */
	int *freq_list;

	/**
	 * scan_cur_freq - Whether to scan only the current channel
	 *
	 * If true, attempt to scan only the current channel if any other
	 * VIFs on this radio are already associated on a particular channel.
	 */
	int scan_cur_freq;

	/**
	 * changed_parameters - Bitmap of changed parameters since last update
	 */
	unsigned int changed_parameters;

	/**
	 * disassoc_low_ack - Disassocicate stations with massive packet loss
	 */
	int disassoc_low_ack;

	/**
	 * interworking - Whether Interworking (IEEE 802.11u) is enabled
	 */
	int interworking;

	/**
	 * access_network_type - Access Network Type
	 *
	 * When Interworking is enabled, scans will be limited to APs that
	 * advertise the specified Access Network Type (0..15; with 15
	 * indicating wildcard match).
	 */
	int access_network_type;

	/**
	 * hessid - Homogenous ESS identifier
	 *
	 * If this is set (any octet is non-zero), scans will be used to
	 * request response only from BSSes belonging to the specified
	 * Homogeneous ESS. This is used only if interworking is enabled.
	 */
	u8 hessid[ETH_ALEN];

	/**
	 * hs20 - Hotspot 2.0
	 */
	int hs20;

	/**
	 * pbc_in_m1 - AP mode WPS probing workaround for PBC with Windows 7
	 *
	 * Windows 7 uses incorrect way of figuring out AP's WPS capabilities
	 * by acting as a Registrar and using M1 from the AP. The config
	 * methods attribute in that message is supposed to indicate only the
	 * configuration method supported by the AP in Enrollee role, i.e., to
	 * add an external Registrar. For that case, PBC shall not be used and
	 * as such, the PushButton config method is removed from M1 by default.
	 * If pbc_in_m1=1 is included in the configuration file, the PushButton
	 * config method is left in M1 (if included in config_methods
	 * parameter) to allow Windows 7 to use PBC instead of PIN (e.g., from
	 * a label in the AP).
	 */
	int pbc_in_m1;

	/**
	 * autoscan - Automatic scan parameters or %NULL if none
	 *
	 * This is an optional set of parameters for automatic scanning
	 * within an interface in following format:
	 * <autoscan module name>:<module parameters>
	 */
	char *autoscan;

	/**
	 * wps_nfc_pw_from_config - NFC Device Password was read from config
	 *
	 * This parameter can be determined whether the NFC Device Password was
	 * included in the configuration (1) or generated dynamically (0). Only
	 * the former case is re-written back to the configuration file.
	 */
	int wps_nfc_pw_from_config;

	/**
	 * wps_nfc_dev_pw_id - NFC Device Password ID for password token
	 */
	int wps_nfc_dev_pw_id;

	/**
	 * wps_nfc_dh_pubkey - NFC DH Public Key for password token
	 */
	struct wpabuf *wps_nfc_dh_pubkey;

	/**
	 * wps_nfc_dh_privkey - NFC DH Private Key for password token
	 */
	struct wpabuf *wps_nfc_dh_privkey;

	/**
	 * wps_nfc_dev_pw - NFC Device Password for password token
	 */
	struct wpabuf *wps_nfc_dev_pw;

	/**
	 * ext_password_backend - External password backend or %NULL if none
	 *
	 * format: <backend name>[:<optional backend parameters>]
	 */
	char *ext_password_backend;

	/*
	 * p2p_go_max_inactivity - Timeout in seconds to detect STA inactivity
	 *
	 * This timeout value is used in P2P GO mode to clean up
	 * inactive stations.
	 * By default: 300 seconds.
	 */
	int p2p_go_max_inactivity;

	struct hostapd_wmm_ac_params wmm_ac_params[4];

	/**
	 * auto_interworking - Whether to use network selection automatically
	 *
	 * 0 = do not automatically go through Interworking network selection
	 *     (i.e., require explicit interworking_select command for this)
	 * 1 = perform Interworking network selection if one or more
	 *     credentials have been configured and scan did not find a
	 *     matching network block
	 */
	int auto_interworking;

	/**
	 * p2p_go_ht40 - Default mode for HT40 enable when operating as GO.
	 *
	 * This will take effect for p2p_group_add, p2p_connect, and p2p_invite.
	 * Note that regulatory constraints and driver capabilities are
	 * consulted anyway, so setting it to 1 can't do real harm.
	 * By default: 0 (disabled)
	 */
	int p2p_go_ht40;

	/**
	 * p2p_disabled - Whether P2P operations are disabled for this interface
	 */
	int p2p_disabled;

	/**
	 * p2p_no_group_iface - Whether group interfaces can be used
	 *
	 * By default, wpa_supplicant will create a separate interface for P2P
	 * group operations if the driver supports this. This functionality can
	 * be disabled by setting this parameter to 1. In that case, the same
	 * interface that was used for the P2P management operations is used
	 * also for the group operation.
	 */
	int p2p_no_group_iface;

	/**
	 * okc - Whether to enable opportunistic key caching by default
	 *
	 * By default, OKC is disabled unless enabled by the per-network
	 * proactive_key_caching=1 parameter. okc=1 can be used to change this
	 * default behavior.
	 */
	int okc;

	/**
	 * pmf - Whether to enable/require PMF by default
	 *
	 * By default, PMF is disabled unless enabled by the per-network
	 * ieee80211w=1 or ieee80211w=2 parameter. pmf=1/2 can be used to change
	 * this default behavior.
	 */
	enum mfp_options pmf;

	/**
	 * sae_groups - Preference list of enabled groups for SAE
	 *
	 * By default (if this parameter is not set), the mandatory group 19
	 * (ECC group defined over a 256-bit prime order field) is preferred,
	 * but other groups are also enabled. If this parameter is set, the
	 * groups will be tried in the indicated order.
	 */
	int *sae_groups;

	/**
	 * dtim_period - Default DTIM period in Beacon intervals
	 *
	 * This parameter can be used to set the default value for network
	 * blocks that do not specify dtim_period.
	 */
	int dtim_period;

	/**
	 * beacon_int - Default Beacon interval in TU
	 *
	 * This parameter can be used to set the default value for network
	 * blocks that do not specify beacon_int.
	 */
	int beacon_int;

	/**
	 * ap_vendor_elements: Vendor specific elements for Beacon/ProbeResp
	 *
	 * This parameter can be used to define additional vendor specific
	 * elements for Beacon and Probe Response frames in AP/P2P GO mode. The
	 * format for these element(s) is a hexdump of the raw information
	 * elements (id+len+payload for one or more elements).
	 */
	struct wpabuf *ap_vendor_elements;

	/**
	 * ignore_old_scan_res - Ignore scan results older than request
	 *
	 * The driver may have a cache of scan results that makes it return
	 * information that is older than our scan trigger. This parameter can
	 * be used to configure such old information to be ignored instead of
	 * allowing it to update the internal BSS table.
	 */
	int ignore_old_scan_res;

	/**
	 * sched_scan_interval -  schedule scan interval
	 */
	unsigned int sched_scan_interval;

	/**
	 * tdls_external_control - External control for TDLS setup requests
	 *
	 * Enable TDLS mode where external programs are given the control
	 * to specify the TDLS link to get established to the driver. The
	 * driver requests the TDLS setup to the supplicant only for the
	 * specified TDLS peers.
	 *
	 */
	int tdls_external_control;
};
```

### network节点

wpa_supplicant.conf文件中每个network节点都是一个保存的网络, 存储了网络的名称（ssid），密码（psk），加密方式（WPA_PSK），优先级（priority）

WIFI网络有多种加密方式，每种加密方式（wpa_psk，wep，open，wapi，各种eap等）的节点书写方式都不同，具体可以参考源代码中[wpa_supplicant.conf](http://w1.fi/cgit/hostap/plain/wpa_supplicant/wpa_supplicant.conf)文件

network节点的结构体`struct wpa_ssid`

``` C
/**
 * struct wpa_ssid - Network configuration data
 *
 * This structure includes all the configuration variables for a network. This
 * data is included in the per-interface configuration data as an element of
 * the network list, struct wpa_config::ssid. Each network block in the
 * configuration is mapped to a struct wpa_ssid instance.
 */
struct wpa_ssid {
	/**
	 * next - Next network in global list
	 *
	 * This pointer can be used to iterate over all networks. The head of
	 * this list is stored in the ssid field of struct wpa_config.
	 */
	struct wpa_ssid *next;

	/**
	 * pnext - Next network in per-priority list
	 *
	 * This pointer can be used to iterate over all networks in the same
	 * priority class. The heads of these list are stored in the pssid
	 * fields of struct wpa_config.
	 */
	struct wpa_ssid *pnext;

	/**
	 * id - Unique id for the network
	 *
	 * This identifier is used as a unique identifier for each network
	 * block when using the control interface. Each network is allocated an
	 * id when it is being created, either when reading the configuration
	 * file or when a new network is added through the control interface.
	 */
	int id;

	/**
	 * priority - Priority group
	 *
	 * By default, all networks will get same priority group (0). If some
	 * of the networks are more desirable, this field can be used to change
	 * the order in which wpa_supplicant goes through the networks when
	 * selecting a BSS. The priority groups will be iterated in decreasing
	 * priority (i.e., the larger the priority value, the sooner the
	 * network is matched against the scan results). Within each priority
	 * group, networks will be selected based on security policy, signal
	 * strength, etc.
	 *
	 * Please note that AP scanning with scan_ssid=1 and ap_scan=2 mode are
	 * not using this priority to select the order for scanning. Instead,
	 * they try the networks in the order that used in the configuration
	 * file.
	 */
	int priority;

	/**
	 * ssid - Service set identifier (network name)
	 *
	 * This is the SSID for the network. For wireless interfaces, this is
	 * used to select which network will be used. If set to %NULL (or
	 * ssid_len=0), any SSID can be used. For wired interfaces, this must
	 * be set to %NULL. Note: SSID may contain any characters, even nul
	 * (ASCII 0) and as such, this should not be assumed to be a nul
	 * terminated string. ssid_len defines how many characters are valid
	 * and the ssid field is not guaranteed to be nul terminated.
	 */
	u8 *ssid;

	/**
	 * ssid_len - Length of the SSID
	 */
	size_t ssid_len;

	/**
	 * bssid - BSSID
	 *
	 * If set, this network block is used only when associating with the AP
	 * using the configured BSSID
	 *
	 * If this is a persistent P2P group (disabled == 2), this is the GO
	 * Device Address.
	 */
	u8 bssid[ETH_ALEN];

	/**
	 * bssid_set - Whether BSSID is configured for this network
	 */
	int bssid_set;

	/**
	 * psk - WPA pre-shared key (256 bits)
	 */
	u8 psk[32];

	/**
	 * psk_set - Whether PSK field is configured
	 */
	int psk_set;

	/**
	 * passphrase - WPA ASCII passphrase
	 *
	 * If this is set, psk will be generated using the SSID and passphrase
	 * configured for the network. ASCII passphrase must be between 8 and
	 * 63 characters (inclusive).
	 */
	char *passphrase;

	/**
	 * ext_psk - PSK/passphrase name in external storage
	 *
	 * If this is set, PSK/passphrase will be fetched from external storage
	 * when requesting association with the network.
	 */
	char *ext_psk;

	/**
	 * pairwise_cipher - Bitfield of allowed pairwise ciphers, WPA_CIPHER_*
	 */
	int pairwise_cipher;

	/**
	 * group_cipher - Bitfield of allowed group ciphers, WPA_CIPHER_*
	 */
	int group_cipher;

	/**
	 * key_mgmt - Bitfield of allowed key management protocols
	 *
	 * WPA_KEY_MGMT_*
	 */
	int key_mgmt;

	/**
	 * bg_scan_period - Background scan period in seconds, 0 to disable, or
	 * -1 to indicate no change to default driver configuration
	 */
	int bg_scan_period;

	/**
	 * proto - Bitfield of allowed protocols, WPA_PROTO_*
	 */
	int proto;

	/**
	 * auth_alg -  Bitfield of allowed authentication algorithms
	 *
	 * WPA_AUTH_ALG_*
	 */
	int auth_alg;

	/**
	 * scan_ssid - Scan this SSID with Probe Requests
	 *
	 * scan_ssid can be used to scan for APs using hidden SSIDs.
	 * Note: Many drivers do not support this. ap_mode=2 can be used with
	 * such drivers to use hidden SSIDs.
	 */
	int scan_ssid;

#ifdef IEEE8021X_EAPOL
#define EAPOL_FLAG_REQUIRE_KEY_UNICAST BIT(0)
#define EAPOL_FLAG_REQUIRE_KEY_BROADCAST BIT(1)
	/**
	 * eapol_flags - Bit field of IEEE 802.1X/EAPOL options (EAPOL_FLAG_*)
	 */
	int eapol_flags;

	/**
	 * eap - EAP peer configuration for this network
	 */
	struct eap_peer_config eap;
#endif /* IEEE8021X_EAPOL */

#define NUM_WEP_KEYS 4
#define MAX_WEP_KEY_LEN 16
	/**
	 * wep_key - WEP keys
	 */
	u8 wep_key[NUM_WEP_KEYS][MAX_WEP_KEY_LEN];

	/**
	 * wep_key_len - WEP key lengths
	 */
	size_t wep_key_len[NUM_WEP_KEYS];

	/**
	 * wep_tx_keyidx - Default key index for TX frames using WEP
	 */
	int wep_tx_keyidx;

	/**
	 * proactive_key_caching - Enable proactive key caching
	 *
	 * This field can be used to enable proactive key caching which is also
	 * known as opportunistic PMKSA caching for WPA2. This is disabled (0)
	 * by default unless default value is changed with the global okc=1
	 * parameter. Enable by setting this to 1.
	 *
	 * Proactive key caching is used to make supplicant assume that the APs
	 * are using the same PMK and generate PMKSA cache entries without
	 * doing RSN pre-authentication. This requires support from the AP side
	 * and is normally used with wireless switches that co-locate the
	 * authenticator.
	 *
	 * Internally, special value -1 is used to indicate that the parameter
	 * was not specified in the configuration (i.e., default behavior is
	 * followed).
	 */
	int proactive_key_caching;

	/**
	 * mixed_cell - Whether mixed cells are allowed
	 *
	 * This option can be used to configure whether so called mixed cells,
	 * i.e., networks that use both plaintext and encryption in the same
	 * SSID, are allowed. This is disabled (0) by default. Enable by
	 * setting this to 1.
	 */
	int mixed_cell;

#ifdef IEEE8021X_EAPOL

	/**
	 * leap - Number of EAP methods using LEAP
	 *
	 * This field should be set to 1 if LEAP is enabled. This is used to
	 * select IEEE 802.11 authentication algorithm.
	 */
	int leap;

	/**
	 * non_leap - Number of EAP methods not using LEAP
	 *
	 * This field should be set to >0 if any EAP method other than LEAP is
	 * enabled. This is used to select IEEE 802.11 authentication
	 * algorithm.
	 */
	int non_leap;

	/**
	 * eap_workaround - EAP workarounds enabled
	 *
	 * wpa_supplicant supports number of "EAP workarounds" to work around
	 * interoperability issues with incorrectly behaving authentication
	 * servers. This is recommended to be enabled by default because some
	 * of the issues are present in large number of authentication servers.
	 *
	 * Strict EAP conformance mode can be configured by disabling
	 * workarounds with eap_workaround = 0.
	 */
	unsigned int eap_workaround;

#endif /* IEEE8021X_EAPOL */

	/**
	 * mode - IEEE 802.11 operation mode (Infrastucture/IBSS)
	 *
	 * 0 = infrastructure (Managed) mode, i.e., associate with an AP.
	 *
	 * 1 = IBSS (ad-hoc, peer-to-peer)
	 *
	 * 2 = AP (access point)
	 *
	 * 3 = P2P Group Owner (can be set in the configuration file)
	 *
	 * 4 = P2P Group Formation (used internally; not in configuration
	 * files)
	 *
	 * Note: IBSS can only be used with key_mgmt NONE (plaintext and
	 * static WEP) and key_mgmt=WPA-NONE (fixed group key TKIP/CCMP). In
	 * addition, ap_scan has to be set to 2 for IBSS. WPA-None requires
	 * following network block options: proto=WPA, key_mgmt=WPA-NONE,
	 * pairwise=NONE, group=TKIP (or CCMP, but not both), and psk must also
	 * be set (either directly or using ASCII passphrase).
	 */
	enum wpas_mode {
		WPAS_MODE_INFRA = 0,
		WPAS_MODE_IBSS = 1,
		WPAS_MODE_AP = 2,
		WPAS_MODE_P2P_GO = 3,
		WPAS_MODE_P2P_GROUP_FORMATION = 4,
	} mode;

	/**
	 * disabled - Whether this network is currently disabled
	 *
	 * 0 = this network can be used (default).
	 * 1 = this network block is disabled (can be enabled through
	 * ctrl_iface, e.g., with wpa_cli or wpa_gui).
	 * 2 = this network block includes parameters for a persistent P2P
	 * group (can be used with P2P ctrl_iface commands)
	 */
	int disabled;

	/**
	 * disabled_for_connect - Whether this network was temporarily disabled
	 *
	 * This flag is used to reenable all the temporarily disabled networks
	 * after either the success or failure of a WPS connection.
	 */
	int disabled_for_connect;

	/**
	 * peerkey -  Whether PeerKey handshake for direct links is allowed
	 *
	 * This is only used when both RSN/WPA2 and IEEE 802.11e (QoS) are
	 * enabled.
	 *
	 * 0 = disabled (default)
	 * 1 = enabled
	 */
	int peerkey;

	/**
	 * id_str - Network identifier string for external scripts
	 *
	 * This value is passed to external ctrl_iface monitors in
	 * WPA_EVENT_CONNECTED event and wpa_cli sets this as WPA_ID_STR
	 * environment variable for action scripts.
	 */
	char *id_str;

#ifdef CONFIG_IEEE80211W
	/**
	 * ieee80211w - Whether management frame protection is enabled
	 *
	 * This value is used to configure policy for management frame
	 * protection (IEEE 802.11w). 0 = disabled, 1 = optional, 2 = required.
	 * This is disabled by default unless the default value has been changed
	 * with the global pmf=1/2 parameter.
	 *
	 * Internally, special value 3 is used to indicate that the parameter
	 * was not specified in the configuration (i.e., default behavior is
	 * followed).
	 */
	enum mfp_options ieee80211w;
#endif /* CONFIG_IEEE80211W */

	/**
	 * frequency - Channel frequency in megahertz (MHz) for IBSS
	 *
	 * This value is used to configure the initial channel for IBSS (adhoc)
	 * networks, e.g., 2412 = IEEE 802.11b/g channel 1. It is ignored in
	 * the infrastructure mode. In addition, this value is only used by the
	 * station that creates the IBSS. If an IBSS network with the
	 * configured SSID is already present, the frequency of the network
	 * will be used instead of this configured value.
	 */
	int frequency;

	int ht40;

	/**
	 * wpa_ptk_rekey - Maximum lifetime for PTK in seconds
	 *
	 * This value can be used to enforce rekeying of PTK to mitigate some
	 * attacks against TKIP deficiencies.
	 */
	int wpa_ptk_rekey;

	/**
	 * scan_freq - Array of frequencies to scan or %NULL for all
	 *
	 * This is an optional zero-terminated array of frequencies in
	 * megahertz (MHz) to include in scan requests when searching for this
	 * network. This can be used to speed up scanning when the network is
	 * known to not use all possible channels.
	 */
	int *scan_freq;

	/**
	 * bgscan - Background scan and roaming parameters or %NULL if none
	 *
	 * This is an optional set of parameters for background scanning and
	 * roaming within a network (ESS) in following format:
	 * <bgscan module name>:<module parameters>
	 */
	char *bgscan;

	/**
	 * ignore_broadcast_ssid - Hide SSID in AP mode
	 *
	 * Send empty SSID in beacons and ignore probe request frames that do
	 * not specify full SSID, i.e., require stations to know SSID.
	 * default: disabled (0)
	 * 1 = send empty (length=0) SSID in beacon and ignore probe request
	 * for broadcast SSID
	 * 2 = clear SSID (ASCII 0), but keep the original length (this may be
	 * required with some clients that do not support empty SSID) and
	 * ignore probe requests for broadcast SSID
	 */
	int ignore_broadcast_ssid;

	/**
	 * freq_list - Array of allowed frequencies or %NULL for all
	 *
	 * This is an optional zero-terminated array of frequencies in
	 * megahertz (MHz) to allow for selecting the BSS. If set, scan results
	 * that do not match any of the specified frequencies are not
	 * considered when selecting a BSS.
	 */
	int *freq_list;

	/**
	 * p2p_client_list - List of P2P Clients in a persistent group (GO)
	 *
	 * This is a list of P2P Clients (P2P Device Address) that have joined
	 * the persistent group. This is maintained on the GO for persistent
	 * group entries (disabled == 2).
	 */
	u8 *p2p_client_list;

	/**
	 * num_p2p_clients - Number of entries in p2p_client_list
	 */
	size_t num_p2p_clients;

#ifndef P2P_MAX_STORED_CLIENTS
#define P2P_MAX_STORED_CLIENTS 100
#endif /* P2P_MAX_STORED_CLIENTS */

	/**
	 * psk_list - Per-client PSKs (struct psk_list_entry)
	 */
	struct dl_list psk_list;

	/**
	 * p2p_group - Network generated as a P2P group (used internally)
	 */
	int p2p_group;

	/**
	 * p2p_persistent_group - Whether this is a persistent group
	 */
	int p2p_persistent_group;

	/**
	 * temporary - Whether this network is temporary and not to be saved
	 */
	int temporary;

	/**
	 * export_keys - Whether keys may be exported
	 *
	 * This attribute will be set when keys are determined through
	 * WPS or similar so that they may be exported.
	 */
	int export_keys;

#ifdef ANDROID_P2P
	/**
	 * assoc_retry - Number of times association should be retried.
	 */
	int assoc_retry;
#endif

#ifdef CONFIG_HT_OVERRIDES
	/**
	 * disable_ht - Disable HT (IEEE 802.11n) for this network
	 *
	 * By default, use it if it is available, but this can be configured
	 * to 1 to have it disabled.
	 */
	int disable_ht;

	/**
	 * disable_ht40 - Disable HT40 for this network
	 *
	 * By default, use it if it is available, but this can be configured
	 * to 1 to have it disabled.
	 */
	int disable_ht40;

	/**
	 * disable_sgi - Disable SGI (Short Guard Interval) for this network
	 *
	 * By default, use it if it is available, but this can be configured
	 * to 1 to have it disabled.
	 */
	int disable_sgi;

	/**
	 * disable_max_amsdu - Disable MAX A-MSDU
	 *
	 * A-MDSU will be 3839 bytes when disabled, or 7935
	 * when enabled (assuming it is otherwise supported)
	 * -1 (default) means do not apply any settings to the kernel.
	 */
	int disable_max_amsdu;

	/**
	 * ampdu_factor - Maximum A-MPDU Length Exponent
	 *
	 * Value: 0-3, see 7.3.2.56.3 in IEEE Std 802.11n-2009.
	 */
	int ampdu_factor;

	/**
	 * ampdu_density - Minimum A-MPDU Start Spacing
	 *
	 * Value: 0-7, see 7.3.2.56.3 in IEEE Std 802.11n-2009.
	 */
	int ampdu_density;

	/**
	 * ht_mcs - Allowed HT-MCS rates, in ASCII hex: ffff0000...
	 *
	 * By default (empty string): Use whatever the OS has configured.
	 */
	char *ht_mcs;
#endif /* CONFIG_HT_OVERRIDES */

#ifdef CONFIG_VHT_OVERRIDES
	/**
	 * disable_vht - Disable VHT (IEEE 802.11ac) for this network
	 *
	 * By default, use it if it is available, but this can be configured
	 * to 1 to have it disabled.
	 */
	int disable_vht;

	/**
	 * vht_capa - VHT capabilities to use
	 */
	unsigned int vht_capa;

	/**
	 * vht_capa_mask - mask for VHT capabilities
	 */
	unsigned int vht_capa_mask;

	int vht_rx_mcs_nss_1, vht_rx_mcs_nss_2,
	    vht_rx_mcs_nss_3, vht_rx_mcs_nss_4,
	    vht_rx_mcs_nss_5, vht_rx_mcs_nss_6,
	    vht_rx_mcs_nss_7, vht_rx_mcs_nss_8;
	int vht_tx_mcs_nss_1, vht_tx_mcs_nss_2,
	    vht_tx_mcs_nss_3, vht_tx_mcs_nss_4,
	    vht_tx_mcs_nss_5, vht_tx_mcs_nss_6,
	    vht_tx_mcs_nss_7, vht_tx_mcs_nss_8;
#endif /* CONFIG_VHT_OVERRIDES */

	/**
	 * ap_max_inactivity - Timeout in seconds to detect STA's inactivity
	 *
	 * This timeout value is used in AP mode to clean up inactive stations.
	 * By default: 300 seconds.
	 */
	int ap_max_inactivity;

	/**
	 * dtim_period - DTIM period in Beacon intervals
	 * By default: 2
	 */
	int dtim_period;

	/**
	 * beacon_int - Beacon interval (default: 100 TU)
	 */
	int beacon_int;

	/**
	 * auth_failures - Number of consecutive authentication failures
	 */
	unsigned int auth_failures;

	/**
	 * disabled_until - Network block disabled until this time if non-zero
	 */
	struct os_time disabled_until;

	/**
	 * parent_cred - Pointer to parent wpa_cred entry
	 *
	 * This pointer can be used to delete temporary networks when a wpa_cred
	 * that was used to create them is removed. This pointer should not be
	 * dereferences since it may not be updated in all cases.
	 */
	void *parent_cred;
};
```
