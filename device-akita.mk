#
# Copyright (C) 2021 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

PRODUCT_RELEASE_CONFIG_MAPS += $(wildcard vendor/google_devices/release/phones/pixel_2024_midyear/release_config_map.textproto)

TARGET_LINUX_KERNEL_VERSION := $(RELEASE_KERNEL_AKITA_VERSION)
# Keeps flexibility for kasan and ufs builds
TARGET_KERNEL_DIR ?= $(RELEASE_KERNEL_AKITA_DIR)
TARGET_BOARD_KERNEL_HEADERS ?= $(RELEASE_KERNEL_AKITA_DIR)/kernel-headers

ifneq ($(TARGET_BOOTS_16K),true)
PRODUCT_16K_DEVELOPER_OPTION := $(RELEASE_GOOGLE_AKITA_16K_DEVELOPER_OPTION)
endif

$(call inherit-product-if-exists, vendor/google_devices/akita/prebuilts/device-vendor-akita.mk)
$(call inherit-product-if-exists, vendor/google_devices/zuma/prebuilts/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/zuma/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/akita/proprietary/akita/device-vendor-akita.mk)
$(call inherit-product-if-exists, vendor/google_devices/akita/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/akita/proprietary/WallpapersAkita.mk)

DEVICE_PACKAGE_OVERLAYS += device/google/akita/akita/overlay

ifeq ($(RELEASE_PIXEL_AIDL_AUDIO_HAL_ZUMA),true)
USE_AUDIO_HAL_AIDL := true
endif

include device/google/akita/audio/akita/audio-tables.mk
include device/google/zuma/device-shipping-common.mk
include hardware/google/pixel/vibrator/cs40l26/device.mk
include device/google/gs-common/bcmbt/bluetooth.mk
include device/google/gs-common/touch/gti/gti.mk
include device/google/gs-common/modem/radio_ext/radio_ext.mk

# go/lyric-soong-variables
$(call soong_config_set,lyric,camera_hardware,akita)
$(call soong_config_set,lyric,tuning_product,akita)
$(call soong_config_set,google3a_config,target_device,akita)

# Init files
PRODUCT_COPY_FILES += \
	device/google/akita/conf/init.akita.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.akita.rc

# Recovery files
PRODUCT_COPY_FILES += \
        device/google/akita/conf/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.akita.rc

# Display
PRODUCT_COPY_FILES += \
	device/google/akita/akita/display_colordata_dev_cal0.pb:$(TARGET_COPY_OUT_VENDOR)/etc/display_colordata_dev_cal0.pb \
	device/google/akita/akita/display_golden_google-ak3b_cal0.pb:$(TARGET_COPY_OUT_VENDOR)/etc/display_golden_google-ak3b_cal0.pb \
	device/google/akita/display_golden_external_display_cal2.pb:$(TARGET_COPY_OUT_VENDOR)/etc/display_golden_external_display_cal2.pb

# Display brightness curve
PRODUCT_COPY_FILES += \
	device/google/akita/akita/panel_config_google-ak3b_cal0.pb:$(TARGET_COPY_OUT_VENDOR)/etc/panel_config_google-ak3b_cal0.pb

PRODUCT_VENDOR_PROPERTIES += \
    vendor.primarydisplay.op.hs_hz=120 \
    vendor.primarydisplay.op.ns_hz=60 \
    vendor.primarydisplay.op.peak_refresh_rate=60

# lhbm peak brightness delay: decided by kernel
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += vendor.primarydisplay.lhbm.frames_to_reach_peak_brightness=0

PRODUCT_SOONG_NAMESPACES += device/google/akita/radio/coex

# Coex Configs
PRODUCT_PACKAGES += \
        display_primary_mipi_coex_table \
        display_primary_ssc_coex_table

PRODUCT_PROPERTY_OVERRIDES += \
	persist.vendor.camera.adjust_backend_min_freq_for_1p_front_video_1080p_30fps=1 \
	persist.vendor.camera.adjust_backend_min_freq_for_video_120fps=1 \
	persist.vendor.camera.adjust_cam_uclamp_min_for_1p_rear_video_60fps=1 \
	persist.vendor.camera.extended_launch_boost=1 \
	persist.vendor.camera.optimized_tnr_freq=1 \
	vendor.camera.debug.enable_software_post_sharpen_node=false \
	vendor.camera.allow_sensor_binning_aspect_ratio_to_override_itp_output=false \
	vendor.camera.debug.enable_blending_node=false

# Enable front camera always binning for 720P or smaller resolution
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.camera.front_720P_always_binning=true

# Enable camera exif model/make reporting
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.camera.exif_reveal_make_model=true

# Media Performance Class 13
PRODUCT_PROPERTY_OVERRIDES += ro.odm.build.media_performance_class=33

# NFC
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
	frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
	frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
	frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.nxp.mifare.xml \
	frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.ese.xml \
	device/google/akita/nfc/libnfc-hal-st.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libnfc-hal-st.conf \
	device/google/akita/nfc/libnfc-nci.conf:$(TARGET_COPY_OUT_PRODUCT)/etc/libnfc-nci.conf

PRODUCT_PACKAGES += \
	$(RELEASE_PACKAGE_NFC_STACK) \
	Tag \
	android.hardware.nfc-service.st \
	NfcOverlayAkita

# SecureElement
PRODUCT_PACKAGES += \
	android.hardware.secure_element-service.thales

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.ese.xml \
	frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.uicc.xml \
	device/google/akita/nfc/libse-gto-hal.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libse-gto-hal.conf

# Thermal Config
PRODUCT_COPY_FILES += \
	device/google/akita/thermal_info_config_akita.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config.json \
	device/google/akita/thermal_info_config_charge_akita.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config_charge.json \
	device/google/akita/thermal_info_config_proto.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config_proto.json \
	device/google/akita/thermal_info_config_charge_proto.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config_charge_proto.json

# Power HAL config
PRODUCT_COPY_FILES += \
	device/google/akita/powerhint-akita.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json

# Bluetooth HAL
PRODUCT_COPY_FILES += \
	device/google/akita/bluetooth/bt_vendor_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth/bt_vendor_overlay.conf
PRODUCT_PROPERTY_OVERRIDES += \
    ro.bluetooth.a2dp_offload.supported=true \
    persist.bluetooth.a2dp_offload.disabled=false \
    persist.bluetooth.a2dp_offload.cap=sbc-aac-aptx-aptxhd-ldac

# Bluetooth Tx power caps
PRODUCT_COPY_FILES += \
    device/google/akita/bluetooth/bluetooth_power_limits_AK3.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits.csv \
    device/google/akita/bluetooth/bluetooth_power_limits_AK3_G6GPR_CA.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_G6GPR_CA.csv \
    device/google/akita/bluetooth/bluetooth_power_limits_AK3_G6GPR_EU.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_G6GPR_EU.csv \
    device/google/akita/bluetooth/bluetooth_power_limits_AK3_G6GPR_US.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_G6GPR_US.csv \
    device/google/akita/bluetooth/bluetooth_power_limits_AK3_G8HHN_EU.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_G8HHN_EU.csv \
    device/google/akita/bluetooth/bluetooth_power_limits_AK3_G8HHN_US.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_G8HHN_US.csv \
    device/google/akita/bluetooth/bluetooth_power_limits_AK3_G576D_CA.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_G576D_CA.csv \
    device/google/akita/bluetooth/bluetooth_power_limits_AK3_G576D_EU.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_G576D_EU.csv \
    device/google/akita/bluetooth/bluetooth_power_limits_AK3_G576D_JP.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_G576D_JP.csv \
    device/google/akita/bluetooth/bluetooth_power_limits_AK3_G576D_US.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_G576D_US.csv \
    device/google/akita/bluetooth/bluetooth_power_limits_AK3_GKV4X_CA.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_GKV4X_CA.csv \
    device/google/akita/bluetooth/bluetooth_power_limits_AK3_GKV4X_EU.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_GKV4X_EU.csv \
    device/google/akita/bluetooth/bluetooth_power_limits_AK3_GKV4X_US.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_GKV4X_US.csv

# POF
PRODUCT_PRODUCT_PROPERTIES += \
    ro.bluetooth.finder.supported=true

# DCK properties based on target
PRODUCT_PROPERTY_OVERRIDES += \
    ro.gms.dck.eligible_wcc=2 \
    ro.gms.dck.se_capability=1

# Bluetooth hci_inject test tool
PRODUCT_PACKAGES_ENG += \
    hci_inject

# Bluetooth SAR test tool
PRODUCT_PACKAGES_ENG += \
    sar_test

# Bluetooth EWP test tool
PRODUCT_PACKAGES_ENG += \
    ewp_tool

# Bluetooth AAC VBR
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.a2dp_aac.vbr_supported=true

# Bluetooth Super Wide Band
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.hfp.swb.supported=true

# Bluetooth LE Audio
PRODUCT_PRODUCT_PROPERTIES += \
    ro.bluetooth.leaudio_switcher.supported=true \
    bluetooth.profile.bap.unicast.client.enabled=true \
    bluetooth.profile.csip.set_coordinator.enabled=true \
    bluetooth.profile.hap.client.enabled=true \
    bluetooth.profile.mcp.server.enabled=true \
    bluetooth.profile.ccp.server.enabled=true \
    bluetooth.profile.vcp.controller.enabled=true

# Bluetooth LE Audio enable hardware offloading
PRODUCT_PRODUCT_PROPERTIES += \
    ro.bluetooth.leaudio_offload.supported=true \
    persist.bluetooth.leaudio_offload.disabled=false

# Include Bluetooth soong namespace
PRODUCT_SOONG_NAMESPACES += \
    device/google/akita/bluetooth

# Bluetooth LE Auido offload capabilities setting
PRODUCT_PACKAGES += \
    le_audio_codec_capabilities.xml

# LE Audio Lunch Config for Phase 1 (LE audio toggle hidden by default)
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.leaudio.toggle_visible=true

# LE Audio use classic connection by default
PRODUCT_PRODUCT_PROPERTIES += \
    ro.bluetooth.leaudio.le_audio_connection_by_default=true

# Bluetooth LE Audio CIS handover to SCO
# Set the property only for the controller couldn't support CIS/SCO simultaneously. More detailed in b/242908683.
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.leaudio.notify.idle.during.call=true

# Bluetooth LE Audio enable dual mic SWB call
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.leaudio.dual_bidirection_swb.supported=true

# LE Audio Unicast Allowlist
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.leaudio.allow_list=SM-R510,WF-1000XM5

# Support LE & Classic concurrent encryption (b/330704060)
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.ble.allow_enc_with_bredr=true

# Enable one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode=true

# Override BQR mask to enable LE Audio Choppy report, remove BTRT logging
ifneq (,$(filter eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.bqr.event_mask=295006 \
    persist.bluetooth.bqr.vnd_quality_mask=29 \
    persist.bluetooth.bqr.vnd_trace_mask=0 \
    persist.bluetooth.vendor.btsnoop=true
else
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.bqr.event_mask=295006 \
    persist.bluetooth.bqr.vnd_quality_mask=16 \
    persist.bluetooth.bqr.vnd_trace_mask=0 \
    persist.bluetooth.vendor.btsnoop=false
endif

# Enable Bluetooth AutoOn feature
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.server.automatic_turn_on=true

ifeq ($(USE_AUDIO_HAL_AIDL),true)
# AIDL

# declare use of stereo spatialization
PRODUCT_PROPERTY_OVERRIDES += \
	ro.audio.stereo_spatialization_enabled=true \
	ro.audio.spatializer_enabled=true

else
# HIDL

# Spatial Audio
PRODUCT_PACKAGES += \
	libspatialaudio \
	librondo

# Sound Dose
PRODUCT_PACKAGES += \
	android.hardware.audio.sounddose-vendor-impl \
	audio_sounddose_aoc \

endif

# Audio CCA property
PRODUCT_PROPERTY_OVERRIDES += \
	persist.vendor.audio.cca.enabled=false

# Settings Overlay
PRODUCT_PACKAGES += \
    SettingsAkitaOverlay

# Keymaster HAL
#LOCAL_KEYMASTER_PRODUCT_PACKAGE ?= android.hardware.keymaster@4.1-service

# Gatekeeper HAL
#LOCAL_GATEKEEPER_PRODUCT_PACKAGE ?= android.hardware.gatekeeper@1.0-service.software


# Gatekeeper
# PRODUCT_PACKAGES += \
# 	android.hardware.gatekeeper@1.0-service.software

# Keymint replaces Keymaster
# PRODUCT_PACKAGES += \
# 	android.hardware.security.keymint-service

# Keymaster
#PRODUCT_PACKAGES += \
#	android.hardware.keymaster@4.0-impl \
#	android.hardware.keymaster@4.0-service

#PRODUCT_PACKAGES += android.hardware.keymaster@4.0-service.remote
#PRODUCT_PACKAGES += android.hardware.keymaster@4.1-service.remote
#LOCAL_KEYMASTER_PRODUCT_PACKAGE := android.hardware.keymaster@4.1-service
#LOCAL_KEYMASTER_PRODUCT_PACKAGE ?= android.hardware.keymaster@4.1-service

# PRODUCT_PROPERTY_OVERRIDES += \
# 	ro.hardware.keystore_desede=true \
# 	ro.hardware.keystore=software \
# 	ro.hardware.gatekeeper=software

# PowerStats HAL
PRODUCT_SOONG_NAMESPACES += \
    device/google/akita/powerstats/akita

# WiFi Overlay
PRODUCT_PACKAGES += \
	WifiOverlay2024Mid

# Trusty liboemcrypto.so
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/akita/prebuilts

# include GNSSD
include device/google/akita/location/gnssd/device-gnss.mk

# Set zram size
PRODUCT_VENDOR_PROPERTIES += \
	vendor.zram.size=50p \
	persist.device_config.configuration.disable_rescue_party=true

# Increase thread priority for nodes stop
PRODUCT_VENDOR_PROPERTIES += \
	persist.vendor.camera.increase_thread_priority_nodes_stop=true

# Fingerprint HAL
GOODIX_CONFIG_BUILD_VERSION := g7_trusty
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_common.mk)
ifeq ($(filter factory%, $(TARGET_PRODUCT)),)
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_shipping.mk)
else
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_factory.mk)
endif

# Display
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += vendor.display.lbe.supported=1
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.surface_flinger.set_idle_timer_ms=1500
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.primarydisplay.google-ak3b.temperature_path=/dev/thermal/tz-by-name/display_therm/temp
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.display.read_temp_interval=30

PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.udfps.als_feed_forward_supported=true \
    persist.vendor.udfps.lhbm_controlled_in_hal_supported=true

# Fingerprint exposure compensation
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.udfps.auto_exposure_compensation_supported=true

# OIS with system imu
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.camera.ois_with_system_imu=true

# Vibrator HAL
$(call soong_config_set,haptics,kernel_ver,v$(subst .,_,$(TARGET_LINUX_KERNEL_VERSION)))
ADAPTIVE_HAPTICS_FEATURE := adaptive_haptics_v1
ACTUATOR_MODEL := legacy_zlra_actuator
PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.vibrator.hal.f0.comp.enabled=1 \
    ro.vendor.vibrator.hal.redc.comp.enabled=0 \
	persist.vendor.vibrator.hal.context.enable=false \
	persist.vendor.vibrator.hal.context.scale=40 \
	persist.vendor.vibrator.hal.context.fade=true \
	persist.vendor.vibrator.hal.context.cooldowntime=1600 \
	persist.vendor.vibrator.hal.context.settlingtime=5000

# Override Output Distortion Gain
PRODUCT_VENDOR_PROPERTIES += \
    vendor.audio.hapticgenerator.distortion.output.gain=0.29

# Increment the SVN for any official public releases
ifdef RELEASE_SVN_AKITA
TARGET_SVN ?= $(RELEASE_SVN_AKITA)
else
# Set this for older releases that don't use build flag
TARGET_SVN ?= 21
endif

PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.build.svn=$(TARGET_SVN)

# Set device family property for SMR
PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.device_family=HK3SB3AK3

# Set build properties for SMR builds
ifeq ($(RELEASE_IS_SMR), true)
    ifneq (,$(RELEASE_BASE_OS_AKITA))
        PRODUCT_BASE_OS := $(RELEASE_BASE_OS_AKITA)
    endif
endif

# Set build properties for EMR builds
ifeq ($(RELEASE_IS_EMR), true)
    ifneq (,$(RELEASE_BASE_OS_AKITA))
        PRODUCT_PROPERTY_OVERRIDES += \
        ro.build.version.emergency_base_os=$(RELEASE_BASE_OS_AKITA)
    endif
endif

# Keyboard height ratio and bottom padding in dp for portrait mode
PRODUCT_PRODUCT_PROPERTIES += \
          ro.com.google.ime.kb_pad_port_b=4.19 \
          ro.com.google.ime.height_ratio=1.1

# Enable DeviceAsWebcam support
PRODUCT_VENDOR_PROPERTIES += \
    ro.usb.uvc.enabled=true

# Window Extensions
$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)

# Disable Settings large-screen optimization enabled by Window Extensions
PRODUCT_SYSTEM_PROPERTIES += \
    persist.settings.large_screen_opt.enabled=false

# ETM
ifneq (,$(filter eng, $(TARGET_BUILD_VARIANT)))
$(call inherit-product-if-exists, device/google/common/etm/device-userdebug-modules.mk)
endif

PRODUCT_NO_BIONIC_PAGE_SIZE_MACRO := true
PRODUCT_CHECK_PREBUILT_MAX_PAGE_SIZE := true

# Bluetooth device id
# Akita: 0x410F
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.device_id.product_id=16655
