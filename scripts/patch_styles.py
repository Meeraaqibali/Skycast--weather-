import os

light_styles = """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
        <item name="android:statusBarColor">#FFFFFF</item>
        <item name="android:navigationBarColor">#FFFFFF</item>
        <item name="android:windowLightStatusBar">true</item>
        <item name="android:windowDrawsSystemBarBackgrounds">true</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:attr/colorBackground</item>
        <item name="android:statusBarColor">#FFFFFF</item>
        <item name="android:navigationBarColor">#FFFFFF</item>
        <item name="android:windowLightStatusBar">true</item>
    </style>
</resources>
"""

night_styles = """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
        <item name="android:statusBarColor">#FFFFFF</item>
        <item name="android:navigationBarColor">#FFFFFF</item>
        <item name="android:windowLightStatusBar">true</item>
        <item name="android:windowDrawsSystemBarBackgrounds">true</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">?android:attr/colorBackground</item>
        <item name="android:statusBarColor">#FFFFFF</item>
        <item name="android:navigationBarColor">#FFFFFF</item>
        <item name="android:windowLightStatusBar">true</item>
    </style>
</resources>
"""

v31_styles = """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.SplashScreen">
        <item name="windowSplashScreenBackground">#FFFFFF</item>
        <item name="android:statusBarColor">#FFFFFF</item>
        <item name="android:navigationBarColor">#FFFFFF</item>
        <item name="postSplashScreenTheme">@style/NormalTheme</item>
    </style>
</resources>
"""

launch_bg = """<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />
</layer-list>
"""

os.makedirs("android/app/src/main/res/values", exist_ok=True)
os.makedirs("android/app/src/main/res/values-night", exist_ok=True)
os.makedirs("android/app/src/main/res/values-v31", exist_ok=True)
os.makedirs("android/app/src/main/res/drawable", exist_ok=True)
os.makedirs("android/app/src/main/res/drawable-v21", exist_ok=True)

with open("android/app/src/main/res/values/styles.xml", "w") as f:
    f.write(light_styles)
with open("android/app/src/main/res/values-night/styles.xml", "w") as f:
    f.write(night_styles)
with open("android/app/src/main/res/values-v31/styles.xml", "w") as f:
    f.write(v31_styles)
with open("android/app/src/main/res/drawable/launch_background.xml", "w") as f:
    f.write(launch_bg)
with open("android/app/src/main/res/drawable-v21/launch_background.xml", "w") as f:
    f.write(launch_bg)

print("Native splash & Android 12+ v31 styles patched successfully!")
