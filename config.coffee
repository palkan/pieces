exports.config =
  modules:
    definition: false
    wrapper: false
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'javascripts/pieces.core.js': /^app[\\/]core/
        'javascripts/pieces.js': /^app[\\/](components|plugins)/
        'javascripts/vendor.js': /^(bower_components|vendor)[\\/](?!test)/
        'test/javascripts/test.js': /^test/
        'test/javascripts/test-vendor.js': /^vendor[\\/](?=test)/
      order:
        before:
          [
            'app/core/utils/utils.coffee',
            'app/core/core.coffee',
            'app/core/events/events.coffee',
            'app/core/events/nod_events.coffee',
            'app/core/nod.coffee',
            'app/components/app.coffee',
            'app/components/pieces.coffee',
            'app/plugins/plugin.coffee',
            'app/components/textinput.coffee',
            'test/helpers.coffee'
          ]
        after:
          [
            /^app[\\/]plugins/,
          ]
    stylesheets:
      defaultExtension: 'css'
      joinTo:
        'test/stylesheets/test.css': /^(test|vendor[\\/](?=test))/