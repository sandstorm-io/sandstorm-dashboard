Package.on_use(function (api) {
  api.use('oauth', ['client', 'server']);
  api.use('oauth1', ['client', 'server']);
  api.use('oauth2', ['client', 'server']);
  api.add_files('server.js', 'server');
  api.add_files('client.js', 'client');
});
