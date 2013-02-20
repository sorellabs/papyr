js:
	lsc -c src/media/scripts/*.ls
	browserify -d -o www/media/lib/papyr.js src/media/scripts/scope.js

css:
	stylus -l -w -o www/media/css -I node_modules/ -I node_modules/nib/lib/ -I node_modules/jumper-skirt/src src/media/styles

