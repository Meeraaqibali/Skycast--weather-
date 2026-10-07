import re

path = "android/app/src/main/AndroidManifest.xml"
with open(path, "r") as f:
    c = f.read()

# Add INTERNET + ACCESS_NETWORK_STATE permissions
if "android.permission.INTERNET" not in c:
    c = c.replace(
        "<application",
        '<uses-permission android:name="android.permission.INTERNET" />\n    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />\n    <application',
        1
    )

# Set app label
c = c.replace('android:label="weather_flutter"', 'android:label="SkyCast Weather"')

# Enable cleartext traffic
if "android:usesCleartextTraffic" not in c:
    c = c.replace('<application', '<application\n        android:usesCleartextTraffic="true"', 1)

with open(path, "w") as f:
    f.write(c)

print("Manifest updated")
print("INTERNET permission:", "android.permission.INTERNET" in c)
print("App label SkyCast Weather:", "SkyCast Weather" in c)
