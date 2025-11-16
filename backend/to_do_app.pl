#!/usr/bin/env perl
use lib qw(lib);

use AppConfig;
use Todo;

use Mojolicious::Lite -signatures;
use Mojo::JSON qw(encode_json true false);

my $db_path = AppConfig->db_path;

get '/data' => sub ($c) {
  my @data = Todo->get_all($db_path);
  $c->render(json => encode_json \@data);
};

get '/ping' => sub ($c) {
  $c->render(json => 'pong');
};

app->hook(after_dispatch => sub ($c) {
  $c->res->headers->header('Access-Control-Allow-Origin' => '*');
});

app->start;
