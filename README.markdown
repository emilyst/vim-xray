vim-xray
=====================

This plugin attempts to emulate a feature found in other text editors
such as [Sublime Text] which reveals whitespace only when it's selected.
It is a bit like setting some of the values of the "`listchars`" option
on the fly for visual selections only.

<p align="center">
<img src="example.gif" alt="Example of vim-xray usage" width="600px" />
</p>


Status
------

This plugin is pre-alpha. It's undocumented. It's not guaranteed to
work. It might break everything.

Currently, it implements spaces, tabs, ends of lines, and trailing
whitespace (as a separate setting).


How Does It Work?
-----------------

&nbsp;&nbsp;&nbsp;&nbsp;"_what in the fuck_"

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;— _[Steve Losh]_

It's important to know what you're biting off before installing this
plugin, as it may have performance and visual implications.

Vim provides no way to know when a user has entered or left Visual mode.
For this reason, this plugin refreshes its state on a regular interval
(by default, every tenth of a second) to see if the user has entered or
left Visual mode.

To configure the refresh interval, use a setting like this in your
"`$HOME/.vimrc`." (The units are in milliseconds.)

    let g:xray_refresh_interval = 100

This plugin also abuses highlighting and the "`listchars`"
functionality. Behind the scenes, it swaps the "`listchars`" out while
in Visual mode, and it changes the way they look so that they blend into
the background unless they're selected.


Installing
----------

This plugin requires a version of Vim of 7.4.1154 or greater. Vim must
be compiled with the "`+syntax`," "`+autocmd`," and "`+timers`"
features. (Check the output from "`vim --version`" or "`:help version`"
if you're unsure.)

It may be installed any of the usual ways. Below are the suggested ways
for [Pathogen] and Vim 8's own built-in package method.


### Pathogen ###

If you're using venerable [Pathogen], clone this directory to your
bundles.

    git clone https://github.com/emilyst/vim-xray.git \
      $HOME/.vim/bundle/vim-xray


### Vim Packages ###

This is also installable as a Vim package (see `:help packages`) if
you're running a version of Vim greater than or equal to 8.

Vim's internal package management expects packages in the future to
include a "`start`" and an "`opt`" directory to contain its runtime
paths. As with almost every plugin written in the last decade, I have
not written mine like this. Therefore, you will need to put the entire
plugin under some arbitrary "`start`" directory whose name you probably
have already have chosen (and which doesn't matter). In the below
example, I call this directory "`default`."

    git clone https://github.com/emilyst/vim-xray.git \
      $HOME/.vim/pack/default/start/vim-xray


[Steve Losh]:   http://learnvimscriptthehardway.stevelosh.com
[Sublime Text]: https://www.sublimetext.com
[example]:      example.gif
[Pathogen]:     https://github.com/tpope/vim-pathogen
