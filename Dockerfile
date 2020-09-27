FROM httpd

# Add mod_perl build dependencies
RUN set -x \
    && apt-get update \
    && apt-get install -y libfile-spec-native-perl make gcc libperl-dev libgdbm-dev libapache2-mod-perl2

#  Fetch mod_perl source, build and install it
#  Note: The fetch URL should be adjusted to point to a local mirror
# ADD http://www.eu.apache.org/dist/perl/mod_perl-2.0.11.tar.gz mod_perl-2.0.11.tar.gz
# RUN set -x \
#     && ln -s /usr/lib/x86_64-linux-gnu/libgdbm.so.3.0.0 /usr/lib/libgdbm.so \
#     && tar -zxvf mod_perl-2.0.11.tar.gz \
#     && rm mod_perl-2.0.11.tar.gz \
#     && cd mod_perl-2.0.11 \
#     && perl Makefile.PL MP_APR_CONFIG=/usr/bin/apr-1-config \
#     && make \ 
#     && make install

# Remove mod_perl build dependencies
# RUN set -x \
#     && rm -r mod_perl-2.0.11  \
#     && apt-get purge -y --auto-remove make gcc libperl-dev \
#     && rm -rf /var/lib/apt/lists/*

COPY ./conf/httpd.conf /usr/local/apache2/conf/httpd.conf
