# ---- Config ----
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
ANDROID_DIR := $(ROOT_DIR)/android
IOS_DIR := $(ROOT_DIR)/ios
BUILD_TYPE ?= release
APK_DIR := $(ANDROID_DIR)/app/build/outputs/apk
PATH_TO_RELEASE_APK := $(APK_DIR)/$(BUILD_TYPE)/app-$(BUILD_TYPE).apk

.PHONY: clean-android
clean-android: 
	cd $(ANDROID_DIR) && rm -rf .gradle || true
	cd $(ANDROID_DIR)/app && rm -rf build || true
	cd $(ANDROID_DIR) && ./gradlew clean

# ---- Dev run ----
.PHONY: run
run: 
	npx react-native start

.PHONY: run-android
run-android: 
	npx react-native run-android

.PHONY: run-ios
run-ios: 
	npx react-native run-ios

.PHONY: watchman
watchman:
	watchman watch-del '$(ROOT_DIR)' ; watchman watch-project '$(ROOT_DIR)'

# ---- Build / Release ----
.PHONY: release
release:
	cd $(ANDROID_DIR) && ./gradlew assembleRelease -PversionCode=$(VERSION_CODE) -PversionName=$(VERSION_NAME)

.PHONY: bundle
bundle: 
	cd $(ANDROID_DIR) && ./gradlew bundleRelease -PversionCode=$(VERSION_CODE) -PversionName=$(VERSION_NAME)

# ---- Install / Uninstall / Run ----
.PHONY: install-release
install-release: 
	adb install -r "$(PATH_TO_RELEASE_APK)"

# ---- Utils ----
.PHONY: yarn
yarn: 
	[ -d node_modules ] && rm -rf node_modules || true
	yarn cache clean
	yarn install

.PHONY: check-for-updates
check-for-updates: 
	yarn outdated