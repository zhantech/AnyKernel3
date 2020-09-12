# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
script="$0"
properties() { '
kernel.string=Luuvy kernel from Zamrud Khatulistiwa
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
do.f2fs_patch=1
do.rem_encryption=0
do.force_encryption=0
device.name1=santoni
device.name2=Redmi 4x
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. $home/tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $home/ramdisk/*;
set_perm_recursive 0 0 750 750 $home/ramdisk/init* $home/ramdisk/sbin;
mount -o remount,rw /;
mount -o remount,rw /vendor;
mount -o remount,rw /system;
mount -o remount,rw /sbin;
mount -o remount,rw /data;
mount -o remount,rw /storage;

## AnyKernel install
dump_boot;

# fstab.qcom
if [ -e fstab.qcom ]; then
	fstab=fstab.qcom;
elif [ -e /system/vendor/etc/fstab.qcom ]; then
	fstab=/system/vendor/etc/fstab.qcom;
elif [ -e /system/etc/fstab.qcom ]; then
	fstab=/system/etc/fstab.qcom;
fi;

if [ "$(file_getprop $script do.f2fs_patch)" == 1 ]; then
if [ $(mount | grep f2fs | wc -l) -gt "0" ] &&
   [ $(cat $fstab | grep f2fs | wc -l) -eq "0" ]; then
ui_print " "; ui_print "Found fstab: $fstab";
ui_print "- Adding f2fs support to fstab...";

insert_line $fstab "data        f2fs" before "data        ext4" "/dev/block/bootdevice/by-name/userdata     /data        f2fs    nosuid,nodev,noatime,inline_xattr,data_flush      wait,check,encryptable=footer,formattable,length=-16384";
insert_line $fstab "cache        f2fs" after "data        ext4" "/dev/block/bootdevice/by-name/cache     /cache        f2fs    nosuid,nodev,noatime,inline_xattr,flush_merge,data_flush wait,formattable,check";

	if [ $(cat $fstab | grep f2fs | wc -l) -eq "0" ]; then
		ui_print "- Failed to add f2fs support!";
		exit 1;
	fi;
elif [ $(mount | grep f2fs | wc -l) -gt "0" ] &&
     [ $(cat $fstab | grep f2fs | wc -l) -gt "0" ]; then
	ui_print " "; ui_print "Found fstab: $fstab";
	ui_print "- F2FS supported!";
fi;
fi; #f2fs_patch

if [ $(cat $fstab | grep forceencypt | wc -l) -gt "0" ]; then
	ui_print " "; ui_print "Force encryption is enabled";
	if [ "$(file_getprop $script do.rem_encryption)" == 0 ]; then
		ui_print "- Force encryption removal is off!";
	else
		ui_print "- Force encryption removal is on!";
	fi;
elif [ $(cat $fstab | grep encryptable | wc -l) -gt "0" ]; then
	ui_print " "; ui_print "Force encryption is not enabled";
	if [ "$(file_getprop $script do.force_encryption)" == 0 ]; then
		ui_print "- Force encryption is off!";
	else
		ui_print "- Force encryption is on!";
	fi;
fi;

if [ "$(file_getprop $script do.rem_encryption)" == 1 ] &&
   [ $(cat $fstab | grep forceencypt | wc -l) -gt "0" ]; then
	sed -i 's/forceencrypt/encryptable/g' $fstab
	if [ $(cat $fstab | grep forceencrypt | wc -l) -eq "0" ]; then
		ui_print "- Removed force encryption flag!";
	else
		ui_print "- Failed to remove force encryption!";
		exit 1;
	fi;
elif [ "$(file_getprop $script do.force_encryption)" == 1 ] &&
     [ $(cat $fstab | grep encryptable | wc -l) -gt "0" ]; then
	sed -i 's/encryptable/forceencrypt/g' $fstab
	if [ $(cat $fstab | grep encryptable | wc -l) -eq "0" ]; then
		ui_print "- Added force encryption flag!";
	else
		ui_print "- Failed to add force encryption!";
		exit 1;
	fi;
fi;

# Set Android version for kernel
ver="$(file_getprop /system/build.prop ro.build.version.release)"
if [ ! -z "$ver" ]; then
  patch_cmdline "androidboot.version" "androidboot.version=$ver"
else
  patch_cmdline "androidboot.version" ""
fi;

# Clean up other kernels' ramdisk files before installing ramdisk
rm -rf /system/vendor/etc/init/init.spectrum.rc
rm -rf /system/vendor/etc/init/init.spectrum.sh
rm -rf /system/vendor/etc/init/hw/init.spectrum.rc
rm -rf /system/vendor/etc/init/hw/init.spectrum.sh
rm -rf /system/etc/init/init.spectrum.rc
rm -rf /system/etc/init/init.spectrum.sh
rm -rf /init.spectrum.rc
rm -rf /init.spectrum.sh
rm -rf /init.performance_profiles.rc
rm -rf /sbin/spa
rm -rf /system/storage/emulated/0/Spectrum/profiles/
rm -rf /data/media/0/Spectrum/profiles/
rm -rf /data/media/0/Spectrum/Profiles/
rm -rf /data/media/0/spectrum/
rm -rf /data/media/0/Spectrum/
rm -rf /storage/emulated/0/spectrum/
rm -rf /storage/emulated/0/Spectrum/
rm -rf /storage/emulated/0/Spectrum/profiles/
rm -rf /storage/emulated/0/Spectrum/Profiles/
rm -rf /storage/emulated/0/Spectrum/profiles/balance.profile
rm -rf /storage/emulated/0/Spectrum/profiles/battery.profile
rm -rf /storage/emulated/0/Spectrum/profiles/gaming.profile
rm -rf /storage/emulated/0/Spectrum/profiles/performance.profile

#Spectrum========================================
cp -rpf $home/ramdisk/init.spectrum.rc /system/vendor/etc/init/init.spectrum.rc
chmod 644 /system/vendor/etc/init/init.spectrum.rc
cp -rpf $home/ramdisk/init.spectrum.sh /system/vendor/etc/init/init.spectrum.sh
chmod 644 /system/vendor/etc/init/init.spectrum.sh
#spectrum write init.rc only##############################
if [ -e init.rc ]; then
	cp -rpf init.rc~ init.rc
		####for init.qcom.rc
		remove_line /system/vendor/etc/init/hw/init.qcom.rc "import /init.spectrum.rc";
		remove_line /system/vendor/etc/init/hw/init.qcom.rc "import /vendor/etc/init/hw/init.spectrum.rc";
		remove_line /system/vendor/etc/init/hw/init.qcom.rc "import /vendor/etc/init/init.spectrum.rc";
		remove_line /system/vendor/etc/init/hw/init.qcom.rc "import /system/etc/init/init.spectrum.rc";
		backup_file /system/vendor/etc/init/hw/init.qcom.rc;
		#for init.rc
		remove_line init.rc "import /init.spectrum.rc";
		remove_line init.rc "import /vendor/etc/init/hw/init.spectrum.rc";
		remove_line init.rc "import /vendor/etc/init/init.spectrum.rc";
		remove_line init.rc "import /system/etc/init/init.spectrum.rc";
		backup_file init.rc;
		insert_line init.rc "init.spectrum.rc" before "import /init.usb.rc" "import /vendor/etc/init/init.spectrum.rc";
	else
		if [ -e /system/vendor/etc/init/hw/init.qcom.rc ]; then
			cp -rpf /system/vendor/etc/init/hw/init.qcom.rc~  /system/vendor/etc/init/hw/init.qcom.rc
				remove_line /system/vendor/etc/init/hw/init.qcom.rc "import /init.spectrum.rc";
				remove_line /system/vendor/etc/init/hw/init.qcom.rc "import /vendor/etc/init/hw/init.spectrum.rc";
				remove_line /system/vendor/etc/init/hw/init.qcom.rc "import /vendor/etc/init/init.spectrum.rc";
				remove_line /system/vendor/etc/init/hw/init.qcom.rc "import /system/etc/init/init.spectrum.rc";
				backup_file /system/vendor/etc/init/hw/init.qcom.rc;
				insert_line /system/vendor/etc/init/hw/init.qcom.rc "init.spectrum.rc" before "import /vendor/etc/init/hw/init.qcom.usb.rc" "import /vendor/etc/init/init.spectrum.rc";
		fi;
fi;
#Spectrum========================================

#remove other file spectrum if any
rm -rf /system/vendor/etc/init/hw/init.spectrum.rc
rm -rf /system/vendor/etc/init/hw/init.spectrum.sh
rm -rf /system/etc/init/init.spectrum.rc
rm -rf /system/etc/init/init.spectrum.sh
rm -rf /init.spectrum.rc
rm -rf /init.spectrum.sh

# fix selinux denials for /init.*.sh
$home/tools/magiskpolicy --load sepolicy --save $home/ramdisk/sepolicy \
"allow init rootfs file execute_no_trans" \
"allow init sysfs_devices_system_cpu file write" \
"allow init sysfs_msms_perf file write" \
"allow init proc file { open write }" \
"allow init sysfs file" \
"allow init vendor_configs_file file execute_no_trans" \
"allow init su process transition" \
"allow init su process { siginh rlimitinh }" \
"allow init sysfs_graphics file { open write }" \
"allow thermal-engine shell_exec file { read open execute }" \
"allow thermal-engine shell_exec file execute_no_trans" \
"allow thermal-engine shell_exec file getattr" \
"allow thermal-engine thermal-engine capability { sys_resource sys_ptrace }" \
"allow thermal-engine toolbox_exec file { execute getattr read open }" \
"allow thermal-engine toolbox_exec file execute_no_trans" \
"allow thermal-engine vendor_toolbox_exec file execute_no_trans" \
"allow thermal-engine system_file file execute_no_trans" \
"allow thermal-engine init dir { search getattr }" \
"allow thermal-engine kernel dir { search getattr }" \
"allow thermal-engine kernel file { read open }" \
"allow thermal-engine init file { read open }" \
"allow thermal-engine vendor_init file { read open }" \
"allow vendor_init proc_dirty_ratio file write" \
"allow vendor_init proc_dirty file write" \
"allow init init udp_socket ioctl" \
"allow init init socket read" \
"allow init object_r chr_file ioctl" \
"allow hal_graphics_composer_default hal_graphics_composer_default netlink_kobject_uevent_socket read" \
"allow hal_graphics_composer_default object_r file { read write open }" \
"allow hal_graphics_composer_default sysfs file { read write open }" \
"allow untrusted_app object_r chr_file { ioctl open read write }" \
"allow surfaceflinger object_r chr_file { read write }" \
"allow priv_app object_r chr_file { getattr ioctl open read write }" \
"allow platform_app object_r chr_file { getattr ioctl open read write }" \
"allow untrusted_app vendor_file file { getattr ioctl open read write }" \
"allow system_server vendor_file file { getattr ioctl open read write }" \
"allow toolbox toolbox capability sys_admin" \
"allow toolbox property_socket sock_file write" \
"allow toolbox default_prop property_service set" \
"allow toolbox init unix_stream_socket connectto" \
"allow toolbox init fifo_file { getattr write }"
# end ramdisk changes

write_boot;
## end install
