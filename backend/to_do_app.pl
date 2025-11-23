#!/usr/bin/env perl
use lib qw(lib);

use AppConfig;
use Todo;

use Mojolicious::Lite -signatures;
use Mojo::JSON qw(encode_json true false);

my $db_path = AppConfig->db_path;

get '/todo' => sub ($c) {
  my @data = Todo->get_not_deleted($db_path);
  $c->render(json => encode_json \@data);
};

put '/todo' => sub ($c) {
  my $input = $c->req->json;
  
  Todo->insert($db_path, $input->{label});
  $c->render(json => {success => 1});
};

del '/todo' => sub ($c) {
  my $input = $c->req->json;

  Todo->delete($db_path, $input->{id});
  $c->render(json => {success => 1});
};

options '/todo' => sub ($c) {
  $c->render(data => '');
};

get '/ping' => sub ($c) {
  $c->render(json => 'pong');
};

app->hook(after_dispatch => sub ($c) {
  $c->res->headers->header('Access-Control-Allow-Origin' => '*');
  $c->res->headers->header('Access-Control-Allow-Methods' => 'GET, OPTIONS, POST, DELETE, PUT');
  $c->res->headers->header('Access-Control-Allow-Headers' => 'Content-Type');
});

app->start;
