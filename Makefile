define help

Supported targets: 'install', 'haskell', 'java', 'python', 'c' or 'run'
'install' will install django + geoip2 from pip and datetime from cabal.
'run' will start the development server on your computer. Ctrl-C will stop it.
language target specify backend choices

to run the project do
	make install
	make [language choice if you don't want python]
	     [java || python || c || haskell]
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
	-rm ./backend/rainbow* ./backend/*.class

install: python
	pip install django
	pip install geoip2
	cabal install datetime

haskell: clean
	cd backend && cp ./languages/rainbow.hs ./ && ghc rainbow.hs
	rm backend/rainbow.*

java: clean
	cd backend && cp ./languages/rainbow.java ./ && javac rainbow.java

python: clean
	cd backend && cp ./languages/rainbow.py ./

c: clean
	cd backend/psa_test_algorithm && make && mv rainbow ../

run:
	cd django && python3 manage.py runserver
