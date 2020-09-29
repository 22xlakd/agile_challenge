#!/usr/bin/env perl

use Mojolicious::Lite -signatures;
use CustomMojolicious::ImageService;
use Mojo::Cache;
use Mojolicious::Plugin::CHI;

plugin 'Config';
plugin 'CHI' => {
  default => {
    driver => 'Memory',
    global => 1,
    cache_size => '1m',
    expires_in => app->config('cache_expires')
  }
};

app->hook(before_server_start => sub ($server, $app) {
    _initialize();
});

get '/images/*id' => { id => undef } => sub ($c) {
    my $page = $c->param('page') || 1;
    my $id = $c->stash('id');
    my $images = _initialize();

    return $c->render(json => { 'status' => 'Unauthorized' }, status => '401') unless $images;

    my $image_service = CustomMojolicious::ImageService->new;
    my $method;
    if($id){
        $method = 'get_single_image';
    }
    else{
        $method = 'get_images';
    }

    my $json_response = $image_service->$method(page => $page, images => $images, id => $id);
    if($json_response->{status} eq 'Unauthorized'){
        $image_service->get_access_token(api_key => app->config('api_key'));

        $json_response = $image_service->$method(page => $page, images => $images, id => $id);
    }

    $c->render(json => $json_response);
};

get '/search/:searched_value' => sub ($c) {
    my $searched_value = $c->stash('searched_value');
    my $image_service = CustomMojolicious::ImageService->new;
    my $images = _initialize();

    my $json_response = $image_service->search_images(
        searched_value => $searched_value,
        images => $images,
        load_extend => app->config('load_extend')
    );

    $c->render(json => $json_response);
};

sub _initialize {
    my $image_service = CustomMojolicious::ImageService->new;

    if(!app->chi->get('access_token')){
        my $access_token = $image_service->get_access_token(api_key => app->config('api_key'));

        if($access_token){
            app->chi('default')->set(access_token => $access_token);
        }
        else{
            return;
        }
    }

    my $images;
    if(app->chi->get('images')){
        $images = app->chi->get('images')
    }
    else{
        $images = $image_service->get_all_images(load_extend => app->config('load_extend'));
        app->chi('default')->set(images => $images);
    }

    return $images;
}

app->start;
