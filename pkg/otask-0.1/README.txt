= otask

* https://github.com/ttscoff/OTask

== DESCRIPTION:

[appscript]: http://appscript.sourceforge.net/

A CLI for OmniFocus. I had an AppleScript/Ruby monstrosity that actually worked with TaskPaper, The Hit List, Things and OmniFocus, but that one got out of hand. I took the good parts of it, concentrated on OmniFocus and converted it to [appscript][]. The result is OTask.

== FEATURES/PROBLEMS:

* Natural language date entry for start and due dates
* TextMate style fragment matching for projects and contexts
* Include notes inline or by piping in
* Optional Growl notifications
- - -
* No repeating tasks

== SYNOPSIS:

OTask uses a custom syntax to allow entry of the various elements of an action in one line of text. The following formats can be used anywhere in the line, with the exception of the flag (!) which must be the last character on the line, preceded by a space.

 * @context			   (fragment, no spaces)
 * \#project             (fragment, no spaces)
 * due(due date)        (can be shortened as d(date))
 * start(start date)    (can be shortened as s(date))
 * (notes)
 * !						(sets task as flagged)
 
Contexts and project specifiers should not include spaces. The algorithm that is used will find the best match for the string you give it, so you only need to include enough of it to distinguish it from other contexts or projects. For example, if I were going to put an action directly into my Markdown QuickTags folder, I could just use "#mdqt" and it will find it. "@corr" will get me the "correspondence" context.

Dates are entered in natural language format. You can type "tomorrow," "in 3 days," "next tuesday," etc. You can also use "+3" to set a date 3 days from the current day, "+7" for a week, and so on.

### Command line options

 -h, --help     Displays help message   
 -q, --quiet    Output as little as possible, overrides verbose   
 -V, --verbose  Verbose output   
 -g, --growl    Use Growl for feedback

== REQUIREMENTS:

* rubygems
* rb-appscript gem 
* chronic gem
* amatch gem

== INSTALL:

* sudo gem install otask

== LICENSE:

(The MIT License)

Copyright (c) Ryan Davis, seattle.rb

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
