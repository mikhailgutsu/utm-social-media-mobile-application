# base/lib/arm64-v8a

## Using

```bash
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export ANDROID_NDK_HOME="$ANDROID_SDK_ROOT/ndk/26.1.10909125"
export READELF="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-readelf"
```

Permissions:

```bash
chmod +x libs/check-16kb.sh
```

Run script:

```bash
bash libs/check-16kb.sh android/app/build/outputs/apk/release/app-release.apk --abi arm64-v8a

bash libs/check-16kb.sh android/app/build/outputs/bundle/release/app-release.aab --abi arm64-v8a
```

### Output

```
LIB                                                        ALIGN      STATUS
------------------------------------------------------------------------------
base/lib/arm64-v8a/libVisionCamera.so                      n/a        BAD
base/lib/arm64-v8a/libappmodules.so                        n/a        BAD
base/lib/arm64-v8a/libbarhopper_v3.so                      n/a        BAD
base/lib/arm64-v8a/libc++_shared.so                        n/a        BAD
base/lib/arm64-v8a/libconceal.so                           n/a        BAD
base/lib/arm64-v8a/libdatastore_shared_counter.so          n/a        BAD
base/lib/arm64-v8a/libfbjni.so                             n/a        BAD
base/lib/arm64-v8a/libgesturehandler.so                    n/a        BAD
base/lib/arm64-v8a/libhermestooling.so                     n/a        BAD
base/lib/arm64-v8a/libhermesvm.so                          n/a        BAD
base/lib/arm64-v8a/libimage_processing_util_jni.so         n/a        BAD
base/lib/arm64-v8a/libimagepipeline.so                     n/a        BAD
base/lib/arm64-v8a/libjsi.so                               n/a        BAD
base/lib/arm64-v8a/libnative-filters.so                    n/a        BAD
base/lib/arm64-v8a/libnative-imagetranscoder.so            n/a        BAD
base/lib/arm64-v8a/libreact_codegen_rnscreens.so           n/a        BAD
base/lib/arm64-v8a/libreact_codegen_rnsvg.so               n/a        BAD
base/lib/arm64-v8a/libreact_codegen_safeareacontext.so     n/a        BAD
base/lib/arm64-v8a/libreactnative.so                       n/a        BAD
base/lib/arm64-v8a/libreanimated.so                        n/a        BAD
base/lib/arm64-v8a/librnscreens.so                         n/a        BAD
base/lib/arm64-v8a/libworklets.so                          n/a        BAD
------------------------------------------------------------------------------
```

Summary: OK=`0`, BAD=`22`, SKIP=`0`
