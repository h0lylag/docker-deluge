FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG DELUGE_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs, aptalca"

# environment variables
ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"

# install software
RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	deluged \
	deluge-console \
	deluge-web \
	p7zip \
	unrar \
	unzip \
	libssl1.0.0 \
	openssl && \
 echo "**** install build deps ****" && \
 apt-get install -y \
	libssl-dev \
	python-dev \
	build-essential \
	libffi-dev \
	python-pip && \
 echo "**** install pip packages ****" && \
 pip install --no-cache-dir -U \
	incremental \
	crypto \
	mako \
	markupsafe \
	pyopenssl \
	service_identity \
	six \
	twisted \
	zope.interface && \
 echo "**** cleanup ****" && \
 apt-get purge -y \
	libssl-dev \
	python-dev \
	build-essential \
	libffi-dev \
	python-pip && \
 apt-get --purge autoremove -y && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

## Allow passwordless login to the web interface 
# Allow correct AND incorrect password to be submitted
RUN sed -i 's/if s.hexdigest() == config\["pwd_sha1"\]:/if True:/' /usr/lib/python2.7/dist-packages/deluge/ui/web/auth.py

# Auto submit blank password
RUN sed -i 's/onShow:function(){this.passwordField.focus(.*)}/onShow:function(){this.onLogin();}/' /usr/lib/python2.7/dist-packages/deluge/ui/web/js/deluge-all.js
##

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8112 58846 58946 58946/udp
VOLUME /config /downloads
