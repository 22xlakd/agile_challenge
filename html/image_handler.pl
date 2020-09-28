#!/usr/bin/perl

use CGI;
use ImageService;

use warnings;
use strict;

my $request = CGI->new;
my $image_id = $request->param('id') || undef;
my $page = $request->param('page') || undef;

my $image_service = ImageService->new();

$image_service->get_all_images();

print $request->header('application/json');

if($image_id){
    return $image_service->get_single_image(id => $image_id);
}
else{
    print $image_service->get_images(page => $page);
}


exit 0;

1;
