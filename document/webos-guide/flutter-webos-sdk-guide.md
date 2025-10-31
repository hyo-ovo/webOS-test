Quick Start
This guide provides the essential steps to get a Flutter for webOS application running.

1. Clone the SDK Repository
   First, clone the flutter-webos SDK from GitHub.

cd flutter-webos-sdk/flutter-webos 2. Installation to Run
Install flutter-webos

3. Quick Command
   Now, prepare your environment and verify the setup.

# 1. Check your environment

flutter-webos doctor -v

# 2. Download necessary artifacts

flutter-webos precache -f

# 3. Check for connected devices

flutter-webos devices

# 4. Create a new native webOS app

flutter-webos create --platforms webos --native-app helloworld

# 5. Navigate to your project

cd helloworld

# 6. Build the app package (.ipk)

flutter-webos build webos --ipk

# 7. Run the app on your device as debug mode

flutter-webos run --debug -d webos_tv
