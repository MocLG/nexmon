APP_ABI ?= armeabi

all: libs/$(APP_ABI)/libsqlite.a

libs/$(APP_ABI)/libsqlite.a: Android.mk
	$(NDK_ROOT)/ndk-build NDK_APPLICATION_MK=`pwd`/Application.mk NDK_APP_OUT=. TARGET_PLATFORM=android-21 APP_ABI=$(APP_ABI)

clean:
	rm -Rf libs
	rm -Rf local

FORCE:
	
