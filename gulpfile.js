var gulp = require('gulp');
var sourcemaps = require('gulp-sourcemaps');
var source = require('vinyl-source-stream');
var buffer = require('vinyl-buffer');
var browserify = require('browserify');
var watchify = require('watchify');
var babel = require('babelify');
var jscs = require('gulp-jscs');
var jshint = require('gulp-jshint');
var notify = require('gulp-notify');

var src = {
  all: './src/**/*.js',
  index: './src/index.js',
  lint: ['./src/**/*.js', './spec/**/*.js']
};

function compile(watch) {
  var bundler = watchify(browserify(src.index, { debug: true }).transform(babel));

  function rebundle() {
    bundler.bundle()
      .on('error',
          function(err) {
            console.error(err);
            this.emit('end');
          }
      )
      .pipe(source('build.js'))
      .pipe(buffer())
      .pipe(sourcemaps.init({ loadMaps: true }))
      .pipe(sourcemaps.write('./'))
      .pipe(gulp.dest('./build'))
      .pipe(notify({
        title: 'Build',
        message: 'Build complete!',
      }));
  }

  if (watch) {
    bundler.on('update', function() {
      console.log('-> bundling...');
      rebundle();
    });
  }

  rebundle();
}

function watch() {
  return compile(true);
}

/* The jshint task runs jshint with ES6 support. */
gulp.task('jshint', function() {
  return gulp.src(src.lint)
    .pipe(jshint('.jshintrc'))
    .pipe(jshint.reporter())
    .pipe(notify({
      title: 'JSHint',
      message: 'JSHint Passed.',
    }));
});

gulp.task('jscs', function() {
  return gulp.src(src.lint)
    .pipe(jscs())
    .pipe(jscs.reporter())
    .pipe(notify({
      title: 'JSCS',
      message: 'JSCS Passed.',
    }));
});

gulp.task('lint', ['jshint', 'jscs']);

gulp.task('build', function() { return compile(); });

gulp.task('watch', function() { return watch(); });

gulp.task('default', ['watch']);
