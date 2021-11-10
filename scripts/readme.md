Pandoc conversion:

`pandoc -s -o home.html -t html https://github.com/AppDaddy-Software-Solutions-Inc/core-wiki/wiki`

or

`pandoc -s -o home.html home.md`

or for all files in the current folder:

`for /r "./" %i in (*.md) do pandoc -f markdown -t html "%~fi" -o "%~dpni.html"`
