package CustomMojolicious::ImageService;

use LWP::UserAgent;
use JSON::XS;
use HTTP::Request;

use Data::Dumper;

use warnings;
use strict;

our $ACCESS_TOKEN = undef;

use constant ITEMS_PER_PAGE => 5;
use constant PAGE => 1;

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub get_access_token {
    my ($self, %args) = @_;

     my $body = {
        'apiKey'  => $args{api_key}
    };

    my $access_token_response = $self->_execute(
        endpoint    => 'http://interview.agileengine.com',
        method      => 'POST',
        path        => '/auth',
        body        => $body
    );

    if($access_token_response->{auth} eq JSON::XS::true){
        $ACCESS_TOKEN = $access_token_response->{token};
    }
    else{
        return 0;
    }

    return $ACCESS_TOKEN;
}

sub get_all_images {
    my ($self, %args) = @_;

    # HERE I ADDED THE LIMIT PARAM BECAUSE I COULDN'T FIND A METHOD THAT RETURNS ALL IMAGES AND ATTRIBUTES,
    # WHITOUT A PARAMETER THE SERVICE RETURNS ONLY THE FIRST PAGE
    my $images = $self->_execute(
        endpoint    => 'http://interview.agileengine.com',
        method      => 'GET',
        path        => '/images?limit=20'
    );

    # TO COMPLETE SEARCH REQUIREMENT #7 I NEED TO GET THE EXTRA INFORMATION OF THE PICTURES
    if($args{load_extend}){
        foreach my $img (@{$images->{pictures}}){
            my $image_detail = $self->get_single_image(id => $img->{id});

            foreach my $k (keys %{$image_detail}){
                $img->{$k} = $image_detail->{$k};
            }
        }
    }

    return $images;
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
    my $final_value = $init_value + ITEMS_PER_PAGE - 1;
    my @pictures;
    for ($init_value..$final_value){
        push @pictures, @{$args{images}->{pictures}}[$_];
    }
    $json_response->{pictures} = \@pictures;

    return $json_response;
}

sub get_single_image {
    my ($self, %args) = @_;

    return {} unless $args{id};

    return $self->_execute(
        endpoint    => 'http://interview.agileengine.com',
        method      => 'GET',
        path        => '/images/'.$args{id}
    );
}

sub search_images {
    my ($self, %args) = @_;

    my @serch_result = ();
    if($args{load_extend}){
        @serch_result = grep {
            $_->{camera} =~ /$args{searched_value}/ig || $_->{author} =~ /$args{searched_value}/ig || $_->{tags} =~ /$args{searched_value}/ig || $_->{full_picture} =~ /$args{searched_value}/ig || $_->{id} =~ /$args{searched_value}/ig || $_->{cropped_picture} =~ /$args{searched_value}/ig
        } @{$args{images}->{pictures}};
    }
    else{
        @serch_result = grep {
            $_->{id} =~ /$args{searched_value}/ig || $_->{cropped_picture} =~ /$args{searched_value}/ig
        } @{$args{images}->{pictures}};
    }

    return { pictures => \@serch_result };
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

    #print STDERR '[' . $args{method} . "] request: url=".$endpoint.$args{path}." headers=". JSON::XS::encode_json(\@headers) . ' body=' . ($body || '{}');

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
