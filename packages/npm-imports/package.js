Npm.depends({
    'csv': '0.4.0',
});

Package.on_use(function (api) {
    api.add_files('import.js', 'server');
});
