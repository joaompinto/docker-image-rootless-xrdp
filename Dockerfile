FROM centos:7 as builder

ENV XRDP_VERSION=0.9.13
ENV XORGXRDP_VERSION=0.2.13
ENV GITHUB_BASE=https://github.com

# Base download & build tools
RUN yum install -y wget which

# XRDP build dependencies
RUN yum install -y \
    finger cmake patch gcc make autoconf libtool automake pkgconfig openssl-devel gettext file \
    pam-devel xorg-x11-server-devel libXfont2-devel libXfixes-devel libjpeg-devel libXrandr-devel  \
    nasm flex bison gcc-c++ libxslt perl-libxml-perl xorg-x11-font-utils xmlto-tex

WORKDIR /build

# Build XRDP
RUN wget "${GITHUB_BASE}/neutrinolabs/xrdp/releases/download/v${XRDP_VERSION}/xrdp-${XRDP_VERSION}.tar.gz"
RUN tar -xzvf xrdp-${XRDP_VERSION}.tar.gz
WORKDIR /build/xrdp-${XRDP_VERSION}
RUN ./bootstrap
RUN ./configure --prefix=/opt/app
RUN make
RUN make install

# BUILD XORGXRDP
WORKDIR /build
RUN wget "${GITHUB_BASE}/neutrinolabs/xorgxrdp/releases/download/v${XORGXRDP_VERSION}/xorgxrdp-${XORGXRDP_VERSION}.tar.gz"
RUN tar -xzvf xorgxrdp-${XORGXRDP_VERSION}.tar.gz
WORKDIR /build/xorgxrdp-${XORGXRDP_VERSION}
RUN ./configure --prefix=/opt/app PKG_CONFIG_PATH=/opt/app/lib/pkgconfig/
RUN make
RUN make install

FROM centos:7

RUN yum install -y xorg-x11-server-Xorg libXrandr
RUN yum install -y xterm

# Needed to authenticate the runtime defined user
RUN yum install -y http://mirror.centos.org/centos/7/sclo/x86_64/rh/Packages/n/nss_wrapper-1.0.3-1.el7.x86_64.rpm 
RUN yum install -y gettext     # We need this for envsubst
RUN yum clean all
COPY passwd.template /

# XRDP binaries and config
COPY --from=builder /opt/app /opt/app/
COPY --from=builder /etc/pam.d/xrdp-sesman /etc/pam.d
COPY --from=builder /etc/xrdp /etc/xrdp/
COPY etc/* /etc/xrdp/

# XORGXRDP binaries and config
COPY --from=builder /usr/lib64/xorg /usr/lib64/xorg
COPY --from=builder /etc/X11/xrdp /etc/X11/xrdp

# set write privilege for group on dynamic dirs
RUN chgrp -R 0 /var/log && chmod -R 770 /var/log 
RUN chgrp -R 0 /run && chmod -R 770 /run

# set read for the config files
RUN chmod -R 755 /etc/xrdp/

# Create non privilege user hjome dir
RUN mkdir /home/developer && chgrp -R 0 /home/developer && chmod -R 770 /home/developer

COPY scripts/entry-point.sh /
COPY scripts/start.sh /

ENTRYPOINT ["/entry-point.sh"]
CMD ["/start.sh"]

EXPOSE 3389

USER 1001
