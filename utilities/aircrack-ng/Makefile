PROGS = airbase-ng airdecap-ng aireplay-ng airolib-ng airtun-ng buddy-ng ivstools tkiptun-ng wpaclean aircrack-ng airdecloak-ng airodump-ng airserv-ng besside-ng easside-ng kstats makeivs-ng packetforge-ng wesside-ng

APP_ABI ?= armeabi
ifeq ($(APP_ABI),arm64-v8a)
APP_MODULES ?= airodump-ng aireplay-ng airdecap-ng packetforge-ng
AIRCRACK_TARGET := libs/$(APP_ABI)/airodump-ng
else
APP_MODULES ?=
AIRCRACK_TARGET := libs/$(APP_ABI)/aircrack-ng
endif

all: $(AIRCRACK_TARGET)

$(AIRCRACK_TARGET): Android.mk ../libsqlite/local/$(APP_ABI)/libsqlite.a ../libcrypto/local/$(APP_ABI)/libcrypto.a ../libssl/local/$(APP_ABI)/libssl.a ../libosdep/local/$(APP_ABI)/libosdep.a
	$(NDK_ROOT)/ndk-build NDK_APPLICATION_MK=`pwd`/Application.mk NDK_APP_OUT=. TARGET_PLATFORM=android-21 APP_ABI=$(APP_ABI) APP_MODULES="$(APP_MODULES)"

../libosdep/local/$(APP_ABI)/libosdep.a: FORCE
	cd ../libosdep && make APP_ABI=$(APP_ABI)

../libsqlite/local/$(APP_ABI)/libsqlite.a: FORCE
	cd ../libsqlite && make APP_ABI=$(APP_ABI)

../libssl/local/$(APP_ABI)/libssl.a: FORCE
	cd ../libssl && make APP_ABI=$(APP_ABI)

../libcrypto/local/$(APP_ABI)/libcrypto.a: FORCE
	cd ../libcrypto && make APP_ABI=$(APP_ABI)

install: libs/$(APP_ABI)/aircrack-ng
	adb push libs/$(APP_ABI)/aireplay-ng /sdcard/
	adb shell 'su -c "mount -o rw,remount /system"'
	adb shell 'su -c "cp /sdcard/aireplay-ng /system/bin/aireplay-ng"'
	adb shell 'su -c "chmod +x /system/bin/aireplay-ng"'

FORCE:

clean:
	rm -Rf libs
	rm -Rf local
