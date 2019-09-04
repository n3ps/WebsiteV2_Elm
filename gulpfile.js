'use strict';

var gulp = require('gulp');
var sass = require('gulp-sass');
var size = require('gulp-size');
var browserSync = require('browser-sync');
var del = require('del');
var elm = require('gulp-elm');

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

gulp.task("serve", ["copy:dev", "images:dev", "js:dev", "sass"], function () {
  browserSync.init({
    server: "./serve"
  });

});
