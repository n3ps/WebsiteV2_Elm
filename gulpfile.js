'use strict';

var gulp = require('gulp');
var sass = require('gulp-sass');
var size = require('gulp-size');
var plumber = require('gulp-plumber');
var browserSync = require('browser-sync');
var del = require('del');
var elm = require('gulp-elm');


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
  return gulp.src(["index.html", "src/assets/images/favicon.ico"])
    .pipe(gulp.dest("serve"))
    .pipe(size({ title: "index.html & favicon" }));
});

gulp.task("elm-init", elm.init);
gulp.task("elm", ["elm-init"], function () {
  return gulp.src("src/Main.elm")
    .pipe(plumber())
    .pipe(elm())
    .on("error", function(err) {
      console.error(err.message);
      browserSync.notify("Elm compile error", 5000);

      fs.writeFileSync("serve/index.html", "<!DOCTYPE html><html><body><pre>" + err.message + "</pre></body></html>");
    })
    .pipe(gulp.dest("serve"));
});

gulp.task("watch", function () {
  //gulp.watch(["src/**/*.elm", ["elm", "copy:dev", reload]);
  //gulp.watch(["assets/scss/**/*.scss"], ["sass", "copy:dev", reload]);
});

gulp.task("serve:dev", ["copy:dev", "images:dev", "js:dev", "sass"], function () {
  browserSync.init({
    server: "./serve"
  });
});

gulp.task("default", ["serve:dev"]);
