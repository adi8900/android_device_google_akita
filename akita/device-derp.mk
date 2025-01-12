#
# SPDX-FileCopyrightText: 2021-2024 The LineageOS Project
# SPDX-FileCopyrightText: 2021-2024 The Calyx Institute
# SPDX-License-Identifier: Apache-2.0
#

$(call inherit-product, $(DEVICE_PATH)/device-derp.mk)

DEVICE_PACKAGE_OVERLAYS += $(DEVICE_PATH)/$(DEVICE_CODENAME)/overlay-derp

PRODUCT_PACKAGES += \
    PixelDisplayServiceOverlayAkita

TARGET_VENDOR_PROP += $(DEVICE_PATH)/$(DEVICE_CODENAME)/vendor.prop

# Init
PRODUCT_PACKAGES += \
    init.recovery.akita.touch.rc
