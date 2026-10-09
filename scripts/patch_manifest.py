import re

path = "android/app/src/main/AndroidManifest.xml"
with open(path, "r") as f:
    c = f.read()

# Add INTERNET + NETWORK + LOCATION permissions
if "android.permission.INTERNET" not in c:
    c = c.replace(
        "<application",
        '<uses-permission android:name="android.permission.INTERNET" />\n    '
        '<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />\n    '
        '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />\n    '
        '<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />\n    '
        '<application',
        1
    )
else:
    # Make sure location perms exist even if INTERNET exists
    if "ACCESS_FINE_LOCATION" not in c:
        c = c.replace(
            '<uses-permission android:name="android.permission.INTERNET" />',
            '<uses-permission android:name="android.permission.INTERNET" />\n    '
            '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />\n    '
            '<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />',
            1
        )

# Set app label + cleartext
c = c.replace('android:label="weather_flutter"', 'android:label="SkyCast Weather"')
if 'android:usesCleartextTraffic' not in c:
    c = c.replace('<application', '<application\n        android:usesCleartextTraffic="true"', 1)

with open(path, "w") as f:
    f.write(c)

print("Manifest patched with location permissions")
