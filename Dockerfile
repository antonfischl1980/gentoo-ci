FROM gentoo/portage:latest as portage

FROM gentoo/stage3:amd64-nomultilib-openrc as builder
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

RUN echo 'FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox"' >>/etc/portage/make.conf && \
    echo 'LINGUAS="en"' >>/etc/portage/make.conf && \
    emerge -tuvDN @world && \
    emerge -C sys-apps/man-pages virtual/man && \
    rm -R /usr/share/{man,doc}/ && \
    emerge -tv --depclean && \
    find /usr/share/locale/ -maxdepth 1 -mindepth 1 \! -name "en*" -print0|xargs -r0 rm -Rv && \
    FEATURES='-usersandbox' emerge --jobs=2 \
	app-admin/sudo \
	app-misc/jq \
	app-portage/gentoolkit \
	dev-util/pkgcheck \
	dev-vcs/git \
	&& \
    emerge -tv --depclean && \
    rm -rf /var/cache/distfiles/* /var/log/*.log && \
    wget "https://www.gentoo.org/dtd/metadata.dtd" -O /var/cache/distfiles/metadata.dtd

COPY repos-gentoo.conf /etc/portage/repos.conf/gentoo.conf

RUN rm -rf /var/db/repos/gentoo && emerge --sync

FROM scratch
COPY --from=builder / /
CMD [ "bash" ]
