FROM registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:latest

MAINTAINER Ben Holmes <bholmes@redhat.com>

# Labels
LABEL name="openjdk18-gradle-openshift" \
      version="1.0" \
      architecture="x86_64"  \
      io.openshift.s2i.scripts-url="image:///opt/s2i" \
      io.k8s.description="Platform for building and running plain Java applications (fat-jar and flat classpath) with Gradle" \
      io.k8s.display-name="Java Applications" \
      io.openshift.tags="builder,java" \
      io.openshift.s2i.destination="/tmp" \
      org.jboss.deployments-dir="/deployments" \
      description="Source To Image (S2I) image for Red Hat OpenShift providing Gradle and OpenJDK 1.8" \
      summary="Source To Image (S2I) image for Red Hat OpenShift providing Gradle and OpenJDK 1.8" \
      io.fabric8.s2i.version.jolokia="1.5.0-redhat-1" \
      io.fabric8.s2i.version.gradle="4.7"
      
COPY scripts/ /opt/s2i/

USER root

# Installation dependencies
RUN mkdir -p /opt/gradle/ && \
	yum-config-manager --disable \*-htb-* \*-rt-* \*-eus* \*-aus* \*-ha-* && \
    yum -y install unzip && \
    yum clean all && \
    rm -rf /var/cache/yum

# Install Gradle from distribution
RUN curl -o /tmp/gradle.zip --retry 5 https://services.gradle.org/distributions/gradle-4.7-bin.zip && \
    unzip -d /opt/gradle /tmp/gradle.zip && \
    find /opt/gradle -maxdepth=1 -type d -name "gradle*" -print0 | xargs -0 mv -t /op/gradle/latest && \
	ln -sf /opt/gradle/latest/bin/gradle /usr/local/bin/gradle
    
RUN chgrp -R 0 /opt/gradle && \
    chgrp -R 0 /opt/s2i && \
    chmod -R g=u /opt/gradle && \
    chmod -R g=u /opt/s2i
    
USER 185