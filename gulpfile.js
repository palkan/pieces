'use strict'

var gulp = require('gulp');
var requireDir = require('require-dir');

global.paths = {
  'js': ['./src/**/*.js', './spec/**/*.js'],
  'src': './src',
  'dist': './dist'
};

// Require all tasks in the 'gulp' folder.
requireDir('./gulp', { recurse: false });

// Default task; start local server & watch for changes.
gulp.task('default', ['watch']);
