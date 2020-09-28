package ImageService;

use LWP::UserAgent;
use JSON::XS;
use HTTP::Request;

use Data::Dumper;

use warnings;
use strict;

our $ACCESS_TOKEN = undef;
our $IMAGES = undef;

use constant ITEMS_PER_PAGE => 5;
use constant PAGE => 1;

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub get_all_images {
    my ($self, %args) = @_;

    my $body = {
        'apiKey'  => '23567b218376f79d9415'
    };

    my $access_token_response = $self->_execute(
        endpoint    => 'http://interview.agileengine.com',
        method      => 'POST',
        path        => '/auth',
        body        => $body
    );

    if($access_token_response->{auth} eq JSON::XS::true){
        $ACCESS_TOKEN = $access_token_response->{token};

        # HERE I ADDED THE LIMIT PARAM BECAUSE I COULDN'T FIND A METHOD THAT RETURNS EVERY IMAGE,
        # WHITOUT A PARAMETER THE SERVICE RETURNS ONLY THE FIRST PAGE
        $IMAGES = $self->_execute(
            endpoint    => 'http://interview.agileengine.com',
            method      => 'GET',
            path        => '/images?limit=20'
        );
    }

    return $IMAGES;
}

sub get_images {
    my ($self, %args) = @_;
    my $page = $args{page} || 1;

    my $json_response = {
        has_more    => 1,
        page        => $page,
        pictures    => []
    };

    my $init_value = ($page - 1) * ITEMS_PER_PAGE;
    my $final_value = $init_value + ITEMS_PER_PAGE;
    my @pictures;
    for (my $i=$init_value; $i < $final_value; $i++){
        push @pictures, @{$IMAGES->{pictures}}[$i];
    }
    $json_response->{pictures} = \@pictures;

    return JSON::XS::encode_json($json_response);
}

sub get_single_image {
    my ($self, %args) = @_;

    print "Content-type:text/html\n\n";
    print "<h1>Entro al paquete</h1>";

    print "<p>...".$args{id}."...</p>";
    
    print "<p>....$IMAGES...</p>";

    return;
}

sub search_image {
    my ($self, %args) = @_;

    print "Content-type:text/html\n\n";
    print "<h1>Entro al paquete search</h1>";

    print "<p>...".$args{search_value}."...</p>";

    return;
}

sub _execute {
    my ($self, %args) = @_;

    my $endpoint = $args{endpoint} || undef;

    return undef unless $endpoint;

    my $ua;
    {
        $ua = LWP::UserAgent->new(
            agent       => undef,
            ssl_opts    => {
                SSL_version => 'SSLv23:!SSLv2:!SSLv3', # disable SSLv2 and SSLv3 due to vulnerabilities
            },
            timeout     => 10,
        );
    };

    my @headers = [
        accept              => 'application/json',
        content_type        => 'application/json',
        $ACCESS_TOKEN ? (Authorization => "Bearer $ACCESS_TOKEN") : ()
    ];

    my $body = $args{body} ? JSON::XS::encode_json($args{body}) : undef;

    my $request = HTTP::Request->new(
        $args{method},
        $endpoint.$args{path},
        @headers,
        $body
    );

    my $result = $ua->request($request);

    return unless $result;

    my $content = $result->content();
    my $decoded_result = eval { JSON::XS::decode_json($content) };

    if (my $error = $@) {
        print STDERR ' - Could not decode success response: '.$error;

        return undef;
    }

    return $decoded_result;
}

1;
