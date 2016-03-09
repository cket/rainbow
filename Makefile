define help

Supported targets: 'install', or 'run'
'install' will install django + geoip2 from pip and datetime from cabal.
'run' will start the development server on your computer. Ctrl-C will stop it.
Requires: 
	python 3.5.1
	Java
	Haskell
	gcc
	pip
	cabal

endef
export help
help:
	@echo "$$help"

install:
	pip install django
	pip install geoip2
	cabal install datetime

run:
	cd django && python3 manage.py runserver
