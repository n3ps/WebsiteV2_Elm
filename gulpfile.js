'use strict';

var gulp = require('gulp');
var sass = require('gulp-sass');
var size = require('gulp-size');
var plumber = require('gulp-plumber');
var template = require('gulp-template');
var gulpSequence = require('gulp-sequence');
var git = require('gulp-git');
var uglify = require('gulp-uglify');
var browserSync = require('browser-sync');
var del = require('del');
var elm = require('gulp-elm');
var fs = require('fs');

var reload = browserSync.reload;
var bs;

sass.compiler = require('node-sass');

gulp.task("clean:dev", function(cb) {
  return del(["serve"], cb);
});

gulp.task("sass", function () {
  return gulp.src('./assets/scss/*.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest('serve/assets/stylesheets/'));
});

gulp.task("js:dev", function () {
  return gulp.src("assets/scripts/**")
    .pipe(gulp.dest("serve/assets/scripts"))
    .pipe(size({ title: "scripts" }));
});

gulp.task("images:dev", function () {
  return gulp.src("assets/images/**")
    .pipe(gulp.dest("serve/assets/images"))
    .pipe(size({ title: "images" }));
});

gulp.task("copy:dev", function () {
  return gulp.src(["index.html", "assets/images/favicon.ico"])
    .pipe(gulp.dest("serve"))
    .pipe(size({ title: "index.html & favicon" }));
});

function elmInit() {
  elm.init;
}

gulp.task("elm", gulp.series(elmInit, function () {
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
}));

gulp.task("elm:prod", function (cb) {
  return gulp.src("src/Main.elm")
    .pipe(plumber())
    .pipe(elm({ optimize: true }))
    .on("error", function(err) {
      console.error(err.message);
      return err.message;
    })
    .pipe(uglify())
    .pipe(gulp.dest("dist"));
});

gulp.task('version', function(){
  git.revParse({args:'--short HEAD'}, function (err, hash) {
    if (err) {
      console.log('Can not get git hash');
      hash = "no-hash-here";
    }
    gulp.src('assets/scripts/version.js')
      .pipe(template({'version': '2.0.0-' + hash}))
      .pipe(gulp.dest('serve/assets/scripts/'));
    });
});


gulp.task("watch", function () {
  gulp.watch(["src/**/*.elm"], ["elm", "copy:dev", reload]);
  gulp.watch(["assets/scss/**/*.scss"], ["sass", "copy:dev", reload]);
  gulp.watch(["assets/images/**"], ["copy:dev", reload]);
  gulp.watch(["index.html", "assets/scripts/*.js"], ["copy:dev", reload]);
});

gulp.task("build",
  gulp.series("clean:dev", "sass", "copy:dev", "images:dev", "js:dev", "elm", "version")
);

gulp.task("serve:dev", gulp.series("build", function () {
  browserSync.init({
    server: "./serve"
  });
}));

gulp.task("default", gulp.series("serve:dev", "watch"));
