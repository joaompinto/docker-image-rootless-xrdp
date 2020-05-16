FROM centos:7

ENV XRDP_VERSION=0.9.13
ENV XORGXRDP_VERSION=0.2.13
ENV GITHUB_BASE=https://github.com

RUN yum install -y wget which

RUN yum install -y \
    finger cmake patch gcc make autoconf libtool automake pkgconfig openssl-devel gettext file \
    pam-devel xorg-x11-server-devel libXfont2-devel libXfixes-devel libjpeg-devel libXrandr-devel  \
    nasm flex bison gcc-c++ libxslt perl-libxml-perl xorg-x11-font-utils xmlto-tex

WORKDIR /build

RUN wget "${GITHUB_BASE}/neutrinolabs/xrdp/releases/download/v${XRDP_VERSION}/xrdp-${XRDP_VERSION}.tar.gz"
RUN tar -xzvf xrdp-${XRDP_VERSION}.tar.gz
WORKDIR /build/xrdp-${XRDP_VERSION}
RUN ./bootstrap
RUN ./configure --prefix=/opt/app
RUN make
RUN make install

WORKDIR /build
RUN wget "${GITHUB_BASE}/neutrinolabs/xorgxrdp/releases/download/v${XORGXRDP_VERSION}/xorgxrdp-${XORGXRDP_VERSION}.tar.gz"
RUN tar -xzvf xorgxrdp-${XORGXRDP_VERSION}.tar.gz
WORKDIR /build/xorgxrdp-${XORGXRDP_VERSION}
RUN ./bootstrap
RUN ./configure --prefix=/opt/app PKG_CONFIG_PATH=/opt/app/lib/pkgconfig/
RUN make
RUN make install


#FROM centos:7

RUN yum install -y xorg-x11-server-Xorg xterm

RUN yum install -y http://mirror.centos.org/centos/7/sclo/x86_64/rh/Packages/n/nss_wrapper-1.0.3-1.el7.x86_64.rpm 
RUN yum install -y gettext     # We need this for envsubst
COPY passwd.template /
#COPY --from=builder /opt/app /opt/app/
#COPY --from=builder /etc/xrdp /etc/xrdp/
COPY entry-point.sh /
#COPY etc/* /etc/xrdp/

RUN chgrp -R 0 /var/log && chmod -R 770 /var/log 
RUN chgrp -R 0 /run && chmod -R 770 /run
RUN chgrp -R 0 /etc/xrdp && chmod -R 770 /etc/xrdp
RUN mkdir /home/developer && chgrp -R 0 /home/developer && chmod -R 770 /home/developer

RUN yum clean all
RUN /opt/app/bin/xrdp-keygen xrdp

CMD /entry-point.sh

EXPOSE 3389

USER 1001
