exports.config =
  conventions:
    assets: /(assets|vendor\/assets|font)/
  modules:
    wrapper: (path, data) ->
      if /^app\/demo/.test(path)
        """
          (function(context){
            'use strict';
            var pi = context.pi;
            var utils = pi.utils;
            #{data}
            })(this);
        """
      else if /^(vendor|node_modules|bower_components)/.test(path)
        data
      else
        path = path.replace(/^app\//, '').replace(/\.[^\.]+$/,'')
        unless /^pi(\.|$)/.test(path)
          path = 'pi/'+path
        """
          require.define({'#{path}': function(exports, require, module) {
            #{data}
          }});\n\n
        """
  paths:
    public: 'public'
  server: 
    path: 'app.js' 
    port: 3333 
    base: '/' 
    run: yes
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'js/pieces.core.js': /^(app\/pi.core\.js|app\/core)/
        'js/pieces.components.js': /^(app\/pi.components\.js|app\/(core|components|plugins))/
        'js/pieces.js': /^(app\/pi\.js|app\/(core|components|plugins|controllers|resources|views|net))/
        'js/static.js': /^app\/.*.jade$/
        'js/demo.js': /^app\/demo/      
        'js/vendor.js': /^(bower_components|vendor)[\\/](?!test)/
        'test/js/test.js': /^test/
        'test/js/test-vendor.js': /^vendor[\\/](?=test)/
    stylesheets:
      defaultExtension: 'sass'
      joinTo:
        'css/app.css' : /^app\/styles\/application/
        'css/pieces.css' : /^app\/styles\/pieces/
        'css/vendor.css' : /^(vendor[\\/](?!test))/
        'test/stylesheets/test.css': /^(test|vendor[\\/](?=test))/
      order:
        before: [
          'app/styles/reset.css'
        ]
    templates:
      joinTo: 
        'js/templates.js': /.+\.jade$/
  plugins:
    uglify:
      mangle: 
        toplevel: false
      ignored: /^(bower_components|vendor|test)/
    jade:
      options:
        pretty: yes
      locals:
        baseurl: '/'
        nav: {}
    autoprefixer:
      browsers: ["last 1 version", "> 1%", "ie 9"]