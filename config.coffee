exports.config =
  conventions:
    assets: /(assets|vendor\/assets|fonts)[\\/]/
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
        'js/pieces.js': /^app\/core/
        'js/static.js': /^app\/.*.jade$/
        'js/vendor.js': /^(bower_components|vendor)[\\/](?!test)/
        'test/js/test.helpers.js': /^test\/helpers\.coffee/
        'test/js/test.js': /^test[\\/](?!rvc)/
        'test/js/test.rvc.js': /^test[\\/](?=rvc)/
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