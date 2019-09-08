'use strict';

var gulp = require('gulp');
var sass = require('gulp-sass');
var size = require('gulp-size');
var plumber = require('gulp-plumber');
var template = require('gulp-template');
var git = require('gulp-git');
var uglify = require('gulp-uglify');
var cleanCSS = require('gulp-clean-css');
var browserSync = require('browser-sync');
var del = require('del');
var elm = require('gulp-elm');
var fs = require('fs');

var reload = browserSync.reload;
var bs;

sass.compiler = require('node-sass');

const prodDir = 'dist'

let staticAssets = ["index.html", "assets/images/favicon.ico"];
let stylesheets = ['assets/scss/*.scss', 'assets/scss/*.css'];

gulp.task("clean:dev", function(cb) {
  return del(["serve"], cb);
});

function cleanProd (cb) {
  return del([prodDir], cb);
}

function stylesProd () {
  return gulp.src(stylesheets)
    .pipe(sass().on('error', sass.logError))
    .pipe(cleanCSS())
    .pipe(gulp.dest(prodDir + '/assets/stylesheets/'))
    .pipe(size({ title: "stylesheets" }));
}

function stylesDev () {
  return gulp.src(stylesheets)
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest('serve/assets/stylesheets/'))
    .pipe(size({ title: "stylesheets" }));
}

gulp.task("js:dev", function () {
  return gulp.src("assets/scripts/**")
    .pipe(gulp.dest("serve/assets/scripts"))
    .pipe(size({ title: "scripts" }));
});

function jsProd() {
  return gulp.src("assets/scripts/**")
    .pipe(uglify())
    .pipe(gulp.dest(prodDir + "/assets/scripts"))
    .pipe(size({ title: "scripts" }));
}

gulp.task("images:dev", function () {
  return gulp.src("assets/images/**")
    .pipe(gulp.dest("serve/assets/images"))
    .pipe(size({ title: "images" }));
});

function imagesProd () {
  return gulp.src("assets/images/**")
    .pipe(gulp.dest(prodDir + "/assets/images"))
    .pipe(size({ title: "images" }));
}


gulp.task("copy:dev", function () {
  return gulp.src(staticAssets)
    .pipe(gulp.dest("serve"))
    .pipe(size({ title: "index.html & favicon" }));
});

function copyProd() {
  return gulp.src(staticAssets)
    .pipe(gulp.dest(prodDir))
    .pipe(size({ title: "index.html & favicon" }));
}

function elmDev() {
  return gulp.src("src/Main.elm")
    .pipe(plumber())
    .pipe(elm())
    .on("error", function(err) {
      console.error(err.message);
      browserSync.notify("Elm compile error", 5000);

      fs.writeFileSync("serve/index.html", "<!DOCTYPE html><html><body><pre>" + err.message + "</pre></body></html>");
    })
    .pipe(plumber.stop())
    .pipe(gulp.dest("serve"));
}

function elmProd () {
  return gulp.src("src/Main.elm")
    .pipe(plumber())
    .pipe(elm({ optimize: true }))
    .on("error", function(err) {
      console.error(err.message);
      return err.message;
    })
    .pipe(uglify())
    .pipe(gulp.dest(prodDir));
}

gulp.task('version', function(){
  return git.revParse({args:'--short HEAD'}, function (err, hash) {
    if (err) {
      console.log('Can not get git hash');
      hash = "no-hash-here";
    }
    gulp.src('assets/scripts/version.js')
      .pipe(template({'version': '2.0.0-' + hash}))
      .pipe(gulp.dest('serve/assets/scripts/'));
    });
});


gulp.task("watch", function (cb) {
  gulp.watch(["src/**/*.elm"], gulp.series(elmDev, "copy:dev", reload));
  gulp.watch(["assets/scss/**/*.scss"], gulp.series(stylesDev, "copy:dev", reload));
  gulp.watch(["assets/images/**"], gulp.series("copy:dev", reload));
  gulp.watch(["index.html", "assets/scripts/*.js"], gulp.series("copy:dev", reload));
  cb();
});

gulp.task("build",
  gulp.series("clean:dev", stylesDev, "copy:dev", "images:dev", "js:dev", elmDev, "version")
);

gulp.task("serve:dev", gulp.series("build", function () {
  browserSync.init({
    server: "./serve"
  });
}));

gulp.task("default", gulp.parallel("serve:dev", "watch"));

exports.elmProd = elmProd;
exports.stylesDev = stylesDev;
exports.stylesProd = stylesProd;
exports.jsProd = jsProd;
exports.copyProd = copyProd;

exports.buildProd = gulp.series(cleanProd, gulp.parallel(stylesProd, imagesProd, jsProd, copyProd, elmProd), "version");
