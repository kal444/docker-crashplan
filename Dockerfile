FROM buildpack-deps:jessie
MAINTAINER Kyle Huang <kyle@yellowaxe.com>

# find latest version here: https://www.crashplan.com/en-us/thankyou?os=linux
ENV CRASHPLAN_VERSION=4.7.0
ENV CRASHPLAN_SERVICE_LEVEL=CrashPlan
# ENV CRASHPLAN_SERVICE_LEVEL=CrashPlanPRO

COPY ./install /tmp/install

RUN apt-get update && apt-get install -y --no-install-recommends \
    cpio \
    expect \
    xvfb \
    x11vnc \
    gtk2-engines-murrine \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /tmp/crashplan \
  && ( \
    cd /tmp/crashplan \
    && curl -L https://download.code42.com/installs/linux/install/${CRASHPLAN_SERVICE_LEVEL}/${CRASHPLAN_SERVICE_LEVEL}_${CRASHPLAN_VERSION}_Linux.tgz -o crashplan.tar.gz \
    && tar xvf crashplan.tar.gz \
    && cd crashplan-install \
    && chmod +x /tmp/install/install.exp && /tmp/install/install.exp \
    && chmod +x /tmp/install/config.sh && /tmp/install/config.sh \
    ) \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# expects the following in /conf
#   on first run, they will be create with defaults if not there
# /conf/id - identitfy file out of container to prevent having to adopt account every time
# /conf/conf - all configuration files
# /conf/run.conf - bin/run.conf for memory size configuration
VOLUME /conf

# expects the following in /data
#   on first run, they will be create with defaults if not there
# /data/backupArchives - incoming backup data sets
# /data/cache - cache directory out of container to prevent re-synchronization every time
# /data/log - logs directory
VOLUME /data

# crashplan ports and vnc port
EXPOSE 4242 4243 5900

WORKDIR /usr/local/crashplan

# entrypoint is executed after container startup.
# at this point the volumes are mounted.
# if container is rebuilt, then the links need to
# be updated
ENTRYPOINT ["/entrypoint.sh"]
# this command will be appended to entrypoint script
# as a parameter
CMD [ "/crashplan.sh" ]

