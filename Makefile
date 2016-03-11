define help

Supported targets: 'install', 'haskell', 'java', 'python', or 'run'
'install' will install django + geoip2 from pip and datetime from cabal.
'run' will start the development server on your computer. Ctrl-C will stop it.
language target specify backend choices

to run the project do 
	make install
	make [language choice]
	make run
	then navigate to 127.0.0.1/frontend/ to see the output

Requires: 
	python 3.5.1
	Java 8
	Haskell
	gcc
	pip
	cabal

endef
export help
help:
	@echo "$$help"

clean: 
	-rm ./backend/rainbow*

check: # make sure a language has been specified with the most beautiful one liner in the world \s
	cd backend && python -c "import os; exit(0) if len(list(filter(os.path.isfile, os.listdir('.'))))==1 else exit(1)"

install:
	pip install django
	pip install geoip2
	cabal install datetime

haskell: clean
	cd backend && cp ./languages/rainbow.hs ./ && ghc rainbow.hs
	rm backend/rainbow.*

java: clean
	cd backend && cp ./languages/rainbow.java ./ && javac rainbow.java
	rm backend/rainbow.*
	
python: clean
	cd backend && cp ./languages/rainbow.py ./
	
run: check
	cd django && python3 manage.py runserver
