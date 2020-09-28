#!/usr/bin/perl

use CGI;
use ImageService;

use warnings;
use strict;

my $request = CGI->new;
my $search_value   = $request->param('search_value') || undef;

my $image_service = ImageService->new();

return $image_service->search_image(search_value => $search_value);

exit 0;

1;
