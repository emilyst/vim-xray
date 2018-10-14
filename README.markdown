visual-whitespace.vim
=====================

This plugin attempts to emulate a feature found in other text editors
such as [Sublime Text] which reveals whitespace only when it's selected.
It is a bit like setting the "`space`" and "`tab`" value of the
"`listchars`" option on the fly which only applies within a visual
selection.

**TODO**: Add an example here.


How Does It Work?
-----------------

It's important to know what you're biting off before installing this
plugin, as it may have performance implications.

Vim provides no way to know when a user has entered or left Visual mode.
There are also certain drawing bugs in some circumstances when leaving
Visual mode that have to be worked around.

For these reasons, this plugin refreshes its state on a regular interval
(by default, every tenth of a second) to see if the user has entered or
left Visual mode so that the state of the whitespace on the screen
doesn't get stale.

To configure the refresh interval, use a setting like this in your
"`$HOME/.vimrc`." (The units are in milliseconds.)

    let g:visual_whitespace_refresh_interval = 100

In addition, this plugin uses Vim's conceal feature to accomplish its
job. This means it must manually change some conceal settings in Visual
mode and reset them upon leaving Visual mode. If you have your own
conceal settings for a buffer, they may unexpectedly change in Visual
mode while using this plugin.


Installing
----------

This plugin requires a version of Vim of 7.4.1154 or greater. Vim must
be compiled with the "`+syntax`," "`+conceal`," "`+autocmd`," and
"`+timers`" features. (Check the output from "`vim --version`" or
"`:help version`" if you're unsure.)

It may be installed any of the usual ways. Below are the suggested ways
for [Pathogen] and Vim 8's own built-in package method.


### Pathogen ###

If you're using venerable [Pathogen], clone this directory to your
bundles.

    git clone https://github.com/emilyst/match-count-statusline.git \
      ~/.vim/bundle/match-count-statusline


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

    git clone https://github.com/emilyst/match-count-statusline.git \
      ~/.vim/pack/default/start/match-count-statusline


[Sublime Text]: https://www.sublimetext.com
[Pathogen]: https://github.com/tpope/vim-pathogen
