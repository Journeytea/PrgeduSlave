FROM ubuntu:18.04

USER root

###########################################################################
# Install Nodejs:
###########################################################################

RUN apt-get update && apt-get install curl -y \
    && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && \
    apt-get update && apt-get install -y --no-install-recommends \
    nodejs

###########################################################################
# Install GRADLE and MAVEN:
###########################################################################

ARG GRADLE_MAVEN=5.6.2
ENV PATH=$PATH:/opt/gradle/gradle-$GRADLE_MAVEN/bin
RUN apt-get update && apt-get install -y default-jdk maven \
      && \
    apt-get install zip -y  \
      && \
    apt-get install wget -y \
      && \
    wget https://services.gradle.org/distributions/gradle-$GRADLE_MAVEN-bin.zip \
      && \
    mkdir /opt/gradle \
      && \
    unzip -d /opt/gradle gradle-$GRADLE_MAVEN-bin.zip \
      && \
    rm gradle-$GRADLE_MAVEN-bin.zip \
      && \
    apt-get clean \
		  && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

###########################################################################
# Install Android SDK Library:
###########################################################################

RUN dpkg --add-architecture i386 \
		&& \
	apt-get update && apt-get install -y --no-install-recommends \
		&& \
	apt-get install -y libc6-dev-i386 libc6-i386 zlib1g:i386 libstdc++6:i386  libxcomposite-dev libxcursor-dev:i386 \
		&& \
	apt-get install -y lib32gcc1 lib32ncurses5 lib32z1 libqt5widgets5 libpulse0:i386 pulseaudio libnss3-dev \
		&& \
	apt-get clean \
		&& \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

###########################################################################
# Install Android SDK:
###########################################################################

# Environment variables
ARG SDK_NAME=sdk-tools-linux-4333796
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV ANDROID_SDK_HOME /usr/local/android-sdk-linux
ENV ANDROID_AVD_HOME /root/.android/avd
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator

RUN cd /usr/local \ 
		&& \
	mkdir -p $ANDROID_HOME \
		&& \
	cd $ANDROID_HOME \
		&& \
	wget https://dl.google.com/android/repository/$SDK_NAME.zip -O sdk.zip -q \
		&& \
	unzip sdk.zip >> /dev/null \
		&& \
	rm sdk.zip \
		&& \
	mkdir -p $ANDROID_HOME/.android \
		&& \
	touch $ANDROID_HOME/.android/repositories.cfg

###########################################################################
# Setup Android SDK:
###########################################################################

ARG SDK_SETUP=false
ARG SDK_PLATFORMS
ARG SDK_BUILD_TOOLS

RUN if [ ${SDK_SETUP} = true ]; then \
  yes | $ANDROID_HOME/tools/bin/sdkmanager "platforms;$SDK_PLATFORMS" >> /dev/null \
		&& \
	yes | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;$SDK_BUILD_TOOLS" >> /dev/null \
		&& \
	yes | $ANDROID_HOME/tools/bin/sdkmanager "platform-tools" "emulator" >> /dev/null \
		&& \
	yes | $ANDROID_HOME/tools/bin/sdkmanager --include_obsolete "platforms;android-22" "system-images;android-22;default;x86" >> /dev/null \
;fi

###########################################################################
#Setup JenkinsSlave :
###########################################################################
RUN mkdir -p /home/root/jenkins 
