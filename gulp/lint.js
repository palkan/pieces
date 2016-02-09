'use strict'

var gulp = require('gulp');
var cache = require('gulp-cached');
var jscs = require('gulp-jscs');
var jshint = require('gulp-jshint');
var notify = require('gulp-notify');

gulp.task('jshint', function() {
  return gulp.src(global.paths.js)
    .pipe(cache('linting'))
    .pipe(jshint('.jshintrc'))
    .pipe(jshint.reporter())
    .pipe(notify({
      title: 'JSHint',
      message: 'JSHint Passed.',
    }));
});

gulp.task('jscs', function() {
  return gulp.src(global.paths.js)
    .pipe(cache('linting'))
    .pipe(jscs())
    .pipe(jscs.reporter())
    .pipe(notify({
      title: 'JSCS',
      message: 'JSCS Passed.',
    }));
});

gulp.task('lint', ['jshint', 'jscs']);
