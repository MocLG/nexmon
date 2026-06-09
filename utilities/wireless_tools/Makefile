APP_ABI ?= armeabi

all: libs/$(APP_ABI)/iwconfig libs/$(APP_ABI)/iwlist libs/$(APP_ABI)/iwpriv

libs/$(APP_ABI)/iwconfig: Android.mk
	$(NDK_ROOT)/ndk-build NDK_APPLICATION_MK=`pwd`/Application.mk NDK_APP_OUT=. TARGET_PLATFORM=android-21 APP_ABI=$(APP_ABI)

libs/$(APP_ABI)/iwlist: Android.mk
	$(NDK_ROOT)/ndk-build NDK_APPLICATION_MK=`pwd`/Application.mk NDK_APP_OUT=. TARGET_PLATFORM=android-21 APP_ABI=$(APP_ABI)

libs/$(APP_ABI)/iwpriv: Android.mk
	$(NDK_ROOT)/ndk-build NDK_APPLICATION_MK=`pwd`/Application.mk NDK_APP_OUT=. TARGET_PLATFORM=android-21 APP_ABI=$(APP_ABI)

install: libs/$(APP_ABI)/iwconfig libs/$(APP_ABI)/iwlist libs/$(APP_ABI)/iwpriv
	adb push libs/$(APP_ABI)/iwconfig /sdcard/
	adb push libs/$(APP_ABI)/iwlist /sdcard/
	adb push libs/$(APP_ABI)/iwpriv /sdcard/
	adb shell 'su -c "mount -o rw,remount /system"'
	adb shell 'su -c "cp /sdcard/iwconfig /system/bin/iwconfig"'
	adb shell 'su -c "cp /sdcard/iwlist /system/bin/iwlist"'
	adb shell 'su -c "cp /sdcard/iwpriv /system/bin/iwpriv"'
	adb shell 'su -c "chmod +x /system/bin/iwconfig"'
	adb shell 'su -c "chmod +x /system/bin/iwlist"'
	adb shell 'su -c "chmod +x /system/bin/iwpriv"'

clean:
	rm -Rf libs
	rm -Rf local
