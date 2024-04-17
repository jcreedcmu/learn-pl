sciagawka.html: sciagawka.org
	pandoc --lua-filter=no-export-subtrees.lua -s sciagawka.org -o $@
