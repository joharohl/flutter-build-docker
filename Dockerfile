FROM openjdk:8-jdk-slim

ARG sdk_version=sdk-tools-linux-3859397.zip
ARG android_home=/opt/android/sdk
ARG flutter_version=v1.7.8+hotfix.4
ARG flutter_home=/opt/flutter/

RUN apt-get update \
 && apt-get install --yes \
    curl \
    git \
    lib32stdc++6 \
    xz-utils \
    unzip \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${android_home} && \
    curl --silent --show-error --location --fail --retry 3 --output /tmp/${sdk_version} https://dl.google.com/android/repository/${sdk_version} && \
    unzip -q /tmp/${sdk_version} -d ${android_home} && \
    rm /tmp/${sdk_version}

# Set environmental variables
ENV ANDROID_HOME ${android_home}
ENV ADB_INSTALL_TIMEOUT 120
ENV PATH=${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${flutter_home}/flutter/bin:${PATH}

RUN mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg

RUN yes | sdkmanager --licenses && yes | sdkmanager --update

# Update SDK manager and install system image, platform and build tools
RUN sdkmanager \
  "tools" \
  "platform-tools" \
  "emulator"

RUN sdkmanager \
  "build-tools;28.0.3" \
  "build-tools;29.0.1"

# API_LEVEL string gets replaced by m4
RUN sdkmanager "platforms;android-29"

# Install and setup flutter
RUN mkdir -p ${flutter_home} \
 && cd ${flutter_home} \
 && curl https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${flutter_version}-stable.tar.xz -o flutter.tar.xz \
 && tar xf flutter.tar.xz \
 && rm flutter.tar.xz

