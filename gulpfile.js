/* for gulp4 */
var gulp       = require('gulp');
var uglify     = require('gulp-uglify');//js压缩
var minifyCss  = require("gulp-minify-css");//压缩CSS
var minifyHtml = require("gulp-minify-html");//压缩html
var imagemin   = require('gulp-imagemin');

//压缩html文件
gulp.task('html',function(){
	return gulp.src('./public/**/*.html')
		.pipe(minifyHtml())
		.pipe(gulp.dest('./public'));
})

//压缩css文件
gulp.task('css',function(){
	return gulp.src('./public/**/*.css')
		.pipe(minifyCss({
			compatibility: 'ie8'
		}))
		.pipe(gulp.dest('./public'));
})

//压缩js文件
gulp.task('js',function(){
	return gulp.src(['./public/**/.js'])
		.pipe(uglify())//压缩js
		.pipe(gulp.dest('./public'));
})

//压缩public/demo目录内图片
gulp.task('images', function() {
	return gulp.src('./public/images/**/*.*')
		.pipe(imagemin([
			imagemin.gifsicle({'optimizationLevel': 3}),
/*			imagemin.mozjpeg({'progressive': true}), */
			imagemin.optipng({'optimizationLevel': 7}), 
			imagemin.svgo()
		], 
			{'verbose': true}
		))
		.pipe(gulp.dest('./public/images/'));
});

//默认任务
gulp.task('default',gulp.series(['html', 'css', 'js', 'images']));
