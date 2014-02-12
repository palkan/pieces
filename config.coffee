exports.config =
  modules:
    definition: false
    wrapper: false
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'javascripts/pieces.js': /^app/
        'javascripts/jquery.js': /^bower_components[\\/]jquery/
        'javascripts/vendor.js': /^(bower_components|vendor)[\\/](?!test)(?!jquery)/
        'test/javascripts/test.js': /^test/
        'test/javascripts/test-vendor.js': /^vendor[\\/](?=test)/
      order:
        before:
          [
            'app/core/jquery-pi.js',
            'app/core/utils.coffee',
            'app/core/pieces.coffee',
            'test/helpers.coffee'
          ]
    stylesheets:
      defaultExtension: 'css'
      joinTo:
        'test/stylesheets/test.css': /^(test|vendor[\\/](?=test))/