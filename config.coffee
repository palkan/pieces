exports.config =
  conventions:
    assets: /(assets|vendor\/assets|font)/
  modules:
    definition: false
    wrapper: false
  paths:
    public: 'public'
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'js/static.js': /^app\/.*.jade$/
        'js/pieces.core.js': /^app[\\/]core/
        'js/pieces.js': /^app[\\/](components|plugins)/
        'js/vendor.js': /^(bower_components|vendor)[\\/](?!test)/
        'test/js/test.js': /^test/
        'test/js/test-vendor.js': /^vendor[\\/](?=test)/
      order:
        before:
          [
            'app/core/utils/utils.coffee',
            'app/core/core.coffee',
            'app/core/events/events.coffee',
            'app/core/events/nod_events.coffee',
            'app/core/nod.coffee',
            'app/components/app.coffee',
            'app/components/guess/guesser.coffee',
            'app/components/pieces.coffee',
            /^app[\\/]components/,
            'app/plugins/plugin.coffee',
            'test/helpers.coffee'
          ]
        after:
          [
            /^app[\\/]plugins/,
            'app/components/action_list.coffee'
          ]
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
    jade:
      options:
        pretty: yes
      locals:
        baseurl: '/'
        nav: {}
    autoprefixer:
      browsers: ["last 1 version", "> 1%", "ie 9"]