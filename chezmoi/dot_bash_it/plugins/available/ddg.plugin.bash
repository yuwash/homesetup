cite 'about-plugin'
about-plugin 'Duck Duck Go search within elinks'

function ddg () {
    about 'search with Duck Duck Go'
    example '$ ddg "what does a duck like to do"'
    group 'ddg'

    elinks https://duckduckgo.com/?q="$@"
}
