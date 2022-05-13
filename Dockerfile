FROM gentoo/portage:latest as portage

FROM gentoo/stage3:amd64-nomultilib-openrc as builder
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

RUN echo 'FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox"' >>/etc/portage/make.conf && \
    emerge --jobs=2 \
	app-admin/sudo \
	app-misc/jq \
	app-portage/gentoolkit \
	app-portage/repoman \
	dev-util/pkgcheck \
	dev-vcs/git \
	&& \
    rm -rf /var/cache/distfiles/* /var/log/*.log && \
    wget "https://www.gentoo.org/dtd/metadata.dtd" -O /var/cache/distfiles/metadata.dtd

# initialize cpan
RUN cpan </dev/null || exit 0

COPY repos-gentoo.conf /etc/portage/repos.conf/gentoo.conf

RUN rm -rf /var/db/repos/gentoo && emerge --sync

FROM scratch
COPY --from=builder / /
CMD [ "bash" ]
