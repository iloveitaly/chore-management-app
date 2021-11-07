var gulp = require('gulp');
var plugins = require('gulp-load-plugins')();
var path = require('path');
var stylish = require('jshint-stylish');
var gutil = require('gulp-util');
var bower = require('bower');
var concat = require('gulp-concat');
var sass = require('gulp-sass');
var minifyCss = require('gulp-minify-css');
var rename = require('gulp-rename');
var sh = require('shelljs');
var sourcemaps = require('gulp-sourcemaps');
var mainBowerFiles = require('gulp-main-bower-files');
var connectLr = require('connect-livereload');
var favicons = require("gulp-favicons");
var replace = require("gulp-replace");
var fs = require('fs');
var uglify = require('gulp-uglify');

var paths = {
  sass: ['./mobile/scss/**/*.scss'],
  javascript: [ './mobile/js/**/*.js'],
  templates: ['./mobile/templates/**'],

  mobile: './mobile/',
  mobile_deployment: './public/app',
};

var isProduction = process.env.NODE_ENV === 'production'

gulp.task('default',
  isProduction ? ['move-build', 'favicon-replacement'] : ['move-build', 'js-hint']
);

gulp.task('app-css', function(done) {
  gulp.src(paths.mobile + 'scss/ionic.app.scss')
    // .pipe(sourcemaps.init())
    .pipe(sass())
    .on('error', sass.logError)
    // .pipe(sourcemaps.write())
    // .pipe(gulp.dest('./www/dist'))
    .pipe(minifyCss({
      keepSpecialComments: 0
    }))
    // .pipe(rename({ extname: '.min.css' }))
    .pipe(gulp.dest(paths.mobile_deployment + '/dist'))
    .on('end', done);
});

gulp.task('favicon-generation', ['move-build'], function() {
  return gulp.src(paths.mobile + '/img/icon.png').pipe(favicons({
    appName: "Currency",
    appDescription: "Currency",
    developerName: "Michael Bianco",
    developerURL: "http://mikebian.co/",
    background: "#FFFFFF",
    path: "favicons/",
    url: "http://family.currency/",
    display: "standalone",
    orientation: "portrait",
    version: 1.0,
    logging: false,
    online: false,
    html: "favicon.html",
    pipeHTML: true,
    replace: true
  }))
  .on("error", gutil.log)
  .pipe(gulp.dest(paths.mobile_deployment + '/favicons'));
})

gulp.task('favicon-replacement', ['favicon-generation'], function() {
  return gulp.src(paths.mobile_deployment + '/index.html')
    .pipe(replace('<!--FAVICON-->', fs.readFileSync(paths.mobile_deployment + '/favicons/favicon.html', 'utf8')))
    .pipe(gulp.dest('./public/app/'))
})

// http://www.miwurster.com/add-gits-revision-information-to-your-app-using-gulp/
gulp.task('app-version', function() {
  // NOTE the release version used for `gulp` is the current release, not the next release
  //      manually bump the version stored in `config.js` to ensure that the versions match
  var bumpedVersion = 'v' + (parseInt(process.env.HEROKU_RELEASE_VERSION.substr(1)) + 1)

  return gulp.src(paths.mobile + '/js/config.js')
    .pipe(plugins.replace(/(appVersion:).+'.+'/g, '$1 "' + bumpedVersion + '"'))
    .pipe(plugins.replace(/(environment:).+'.+'/g, '$1 "' + process.env.NODE_ENV + '"'))
    .pipe(gulp.dest(paths.mobile + '/js/', { overwrite: true }));
});

gulp.task('app-javascript', isProduction ? ['app-version'] : [], function() {
  return gulp.src(paths.javascript)
    .pipe(isProduction ? gutil.noop() : sourcemaps.init())
    // .pipe(ngAnnotate({
    //   single_quotes: true
    // }))
    .pipe(concat('app.js'))
    // .pipe(uglify())
    .pipe(isProduction ? gutil.noop() : sourcemaps.write())
    .pipe(gulp.dest(paths.mobile_deployment + '/dist'));
});

gulp.task('bower-javascript', function() {
  return gulp.src('./bower.json')
    .pipe(mainBowerFiles('**/*.js', {
      // debugging: true
    }))
    .pipe(isProduction ? uglify() : gutil.noop())
    .pipe(concat('lib.js'))
    .pipe(gulp.dest(paths.mobile_deployment + '/dist'));
});

gulp.task('bower-css', function() {
  return gulp.src('./bower.json')
    .pipe(mainBowerFiles('**/*.css'))
    .pipe(concat('lib.css'))
    .pipe(gulp.dest(paths.mobile_deployment + '/dist'));
});

// lint js sources based on .jshintrc ruleset
gulp.task('js-hint', function(done) {
  return gulp
    .src(paths.javascript)
    .pipe(plugins.jshint())
    .pipe(plugins.jshint.reporter(stylish))

    // .on('error', errorHandler);
    done();
});

gulp.task('move-fonts', function() {
  return gulp.src([
    path.join(paths.mobile, 'lib/ionic/fonts/*'),
  ], { base: path.join(paths.mobile, 'lib/ionic/fonts/') })
  .pipe(gulp.dest(path.join(paths.mobile_deployment, 'fonts')))
})

gulp.task('build-assets', [
  'app-css',
  'app-javascript',
  'bower-javascript',
  'bower-css',
], function() {

});

gulp.task('move-build', ['move-fonts', 'build-assets'], function() {
  return gulp.src([
      path.join(paths.mobile, 'templates/**/*.*'),
      path.join(paths.mobile, 'img/**/*.*'),
      path.join(paths.mobile, 'index.html'),
    ], { base: paths.mobile })
    .pipe(gulp.dest(paths.mobile_deployment))
    // .on('error', errorHandler);
});

gulp.task('watch', function() {
  plugins.livereload.listen();

  gulp.watch(paths.sass, ['move-build'])
    .on('end', plugins.livereload.changed);
  gulp.watch(paths.javascript, ['move-build', 'js-hint'])
    .on('end', plugins.livereload.changed);
  gulp.watch(paths.templates, ['move-build'])
    .on('end', plugins.livereload.changed);

  // gulp.watch('./public/app/**')
  //   .on('end', plugins.livereload.changed)
});
