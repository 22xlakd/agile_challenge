FROM httpd

# Add mod_perl build dependencies
RUN set -x \
    && apt-get update \
    && apt-get install -y libfile-spec-native-perl make gcc libperl-dev libgdbm-dev libapache2-mod-perl2

ENV PERL_MM_USE_DEFAULT=1
RUN cpan CGI JSON::XS Data::Dumper Mojolicious Mojolicious::Plugin::CHI Config::JSON

COPY ./libs /usr/local/lib/x86_64-linux-gnu/perl/5.28.1
COPY ./conf/httpd.conf /usr/local/apache2/conf/httpd.conf
