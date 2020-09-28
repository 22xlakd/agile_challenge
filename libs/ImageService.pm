package ImageService;

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub get_image {
    my ($self, %args) = @_;

    print "Content-type:text/html\n\n";
    print "<h1>Entro al paquete</h1>";

    print "<p>...".$args{id}."...</p>";

    return;
}

sub search_image {
    my ($self, %args) = @_;

    print "Content-type:text/html\n\n";
    print "<h1>Entro al paquete search</h1>";

    print "<p>...".$args{search_value}."...</p>";

    return;
}

1;
