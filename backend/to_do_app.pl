#!/usr/bin/env perl
use Mojolicious::Lite -signatures;
use Mojo::JSON qw(encode_json true false);
use strict;

get '/data' => sub ($c) {
  my @data = [
    { id => 'todo-1', label => 'Learn Vue', done => false },
    { id => 'todo-2', label => 'Create a Vue project with the CLI', done => true },
    { id => 'todo-3', label => 'Have fun', done => true },
    { id => 'todo-4', label => 'Create a to-do list', done => false },
    { id => 'todo-5', label => 'Write about this', done => false },
  ];
  $c->render(json => encode_json @data)
};

get '/ping' => sub ($c) {
  $c->render(json => 'pong');
};

app->hook(after_dispatch => sub ($c) {
  $c->res->headers->header('Access-Control-Allow-Origin' => '*');
});

app->start;
