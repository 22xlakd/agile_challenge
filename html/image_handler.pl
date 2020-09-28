#!/usr/bin/perl

use CGI;
use ImageService;

use warnings;
use strict;

my $request = CGI->new;
my $image_id   = $request->param('id') || undef;

my $image_service = ImageService->new();

return $image_service->get_image(id => $image_id);

exit 0;

1;
