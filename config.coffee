exports.config =
  conventions:
    assets: /(assets|vendor\/assets|font)[\\/]/
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
        'js/pieces.core.js': /^(app\/pi\.core\.js|app\/core)/
        'js/pieces.components.js': /^(app\/pi\.components\.js|app\/(components|plugins))/
        'js/pieces.rvc.js': /^(app\/pi\.rvc\.js|app\/(controllers|resources|views|net))/
        'js/static.js': /^app\/.*.jade$/
        'js/demo.js': /^app\/demo/      
        'js/vendor.js': /^(bower_components|vendor)[\\/](?!test)/
        'test/js/test.js': /^test/
        'test/js/test-vendor.js': /^vendor[\\/](?=test)/
    stylesheets:
      defaultExtension: 'sass'
      joinTo:
        'css/app.css' : /^(bower_components|app|vendor[\\/](?!test))/
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