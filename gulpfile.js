var gulp = require('gulp');
var minifycss = require('gulp-minify-css');
var babel = require('gulp-babel');
var uglify = require('gulp-uglify');
var htmlmin = require('gulp-htmlmin');
var htmlclean = require('gulp-htmlclean');

gulp.task('minify-css', function () {
return gulp.src('./public/**/*.css')
.pipe(minifycss())
.pipe(gulp.dest('./public'));
});

gulp.task('minify-html', function () {
return gulp.src('./public/**/*.html')
.pipe(htmlclean())
.pipe(htmlmin({
	removeComments: true,
minifyJS: true,
minifyCSS: true,
minifyURLs: true,
}))

.pipe(gulp.dest('./public'))
});

gulp.task('minify-js', function () {
return gulp.src(['./public/**/*.js', '!./public/**/*.min.js'])
.pipe(babel({ presets: ['es2015'] }))
.pipe(uglify())
.pipe(gulp.dest('./public'));
});

gulp.task('default', ['minify-html', 'minify-css', 'minify-js']);
