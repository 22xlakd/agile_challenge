#!/usr/bin/perl

use CGI;
use ImageService;
use CHI;
use Config::JSON;

use warnings;
use strict;

my $request = CGI->new;
my $image_id = $request->param('id') || undef;
my $page = $request->param('page') || undef;
my $searched_value = $request->param('search_value') || undef;

my $config = Config::JSON->new(pathToFile => '/usr/local/apache2/htdocs/config.json');
my $cache = CHI->new (
    driver => 'Memory',
    global => 1,
    expires_in => $config->get('cache_expires')
);

print $request->header('application/json');

my $image_service = ImageService->new();
my $images = _initialize(config => $config, cache => $cache, image_service => $image_service);

if(!$images){
    print $request->header( -status => 401 );
    exit 0;
}

my $json_response;
if($image_id){
    $json_response = $image_service->get_single_image(id => $image_id);
    if($json_response->{status} eq 'Unauthorized'){
        $image_service->get_access_token(api_key => $config->get('api_key'));

        $json_response = $image_service->get_single_image(id => $image_id);
    }
}
elsif($searched_value){
    $json_response = $image_service->search_images(
        searched_value => $searched_value,
        load_extend    => $config->get('load_extend'),
        images         => $images
    );
    if($json_response->{status} eq 'Unauthorized'){
        $image_service->get_access_token(api_key => $config->get('api_key'));
        $json_response = $image_service->search_images(
            searched_value => $searched_value,
            load_extend    => $config->get('load_extend'),
            images         => $images
        );
    }
}
else{
    $json_response = $image_service->get_images(page => $page, images => $images);
    if($json_response->{status} eq 'Unauthorized'){
        $image_service->get_access_token(api_key => $config->get('api_key'));
        $json_response = $image_service->get_images(page => $page, images => $images);
    }
}

print JSON::XS::encode_json($json_response);

sub _initialize {
    my (%args) = @_;

    if(!$args{cache}->get('access_token')){
        my $access_token = $args{image_service}->get_access_token(api_key => $args{config}->get('api_key'));

        if($access_token){
            $args{cache}->set('access_token', $access_token);
        }
        else{
            return;
        }
    }

    my $images;
    if($args{cache}->get('images')){
        $images = $args{cache}->get('images');
    }
    else{
        $images = $args{image_service}->get_all_images(load_extend => $args{config}->get('load_extend'));
        $args{cache}->set('images', $images);
    }

    return $images;
}


1;
