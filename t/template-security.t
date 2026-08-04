use strict;
use warnings;

use Test::More;

use lib 'lib';
use Mojo::Template;

my $template = Mojo::Template->new( vars => 1, auto_escape => 1 );
my $html = $template->render(
  '<a href="<%= $url %>"><%= $name %></a>',
  {
    url  => 'https://example.com/"> <script>alert(1)</script>',
    name => '<img src=x onerror=alert(1)>',
  },
);

unlike($html, qr/<script>|<img /, 'escapes untrusted template values');
like($html, qr/&quot;/, 'escapes an attribute delimiter');
like($html, qr/&lt;img/, 'escapes text markup');

done_testing();
