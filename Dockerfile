FROM gentoo/portage:latest as portage

FROM gentoo/stage3:amd64-nomultilib-openrc
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

RUN echo 'FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox"' >>/etc/portage/make.conf && \
    emerge dev-util/pkgcheck app-portage/repoman app-admin/sudo dev-vcs/git app-portage/gentoolkit app-misc/jq && \
    rm -rf /var/cache/distfiles/*

# initialize cpan
RUN cpan </dev/null || exit 0

COPY repos-gentoo.conf /etc/portage/repos.conf/gentoo.conf

RUN rm -rf /var/db/repos/gentoo && emerge --sync

CMD [ "bash" ]
