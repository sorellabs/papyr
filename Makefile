clean:
	rm -rf build
	rm -rf www/media/lib
	rm -rf www/media/css

js:
	mkdir -p build/scripts
	mkdir -p www/media/lib
	lsc -o build/scripts -c src/media/scripts/*.ls
	browserify -d -o www/media/lib/papyr.js build/scripts/scope.js

css:
	mkdir -p www/media/css
	stylus -l -o www/media/css -I node_modules/ -I node_modules/nib/lib/ -I node_modules/jumper-skirt/src src/media/styles

all:
	make js
	make css

.PHONY: all
.PHONY: clean
