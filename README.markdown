vim-xray
========

This is a Vim plugin to reveal non-printable characters using visual
selections.

<p align="center">
<img src="example.gif" alt="Example of vim-xray usage" width="600px" />
</p>


Contents
--------

* [Introduction](#introduction)
  * [How does it work?](#how-does-it-work)
* [Status](#status)
* [Requirements](#requirements)
* [Installing](#installing)
  * [Pathogen](#pathogen)
  * [Vim Packages](#vim-packages)
* [Usage](#usage)
* [Configuration](#configuration)
  * [`g:xray_enable`](#gxray_enable)
  * [`g:xray_force_redraw`](#gxray_force_redraw)
  * [`g:xray_allowed_filetypes`](#gxray_allowed_filetypes)
  * [`g:xray_ignored_filetypes`](#gxray_ignored_filetypes)
  * [`g:xray_refresh_interval`](#gxray_refresh_interval)
  * [`g:xray_space_char`](#gxray_space_char)
  * [`g:xray_tab_chars`](#gxray_tab_chars)
  * [`g:xray_eol_char`](#gxray_eol_char)
  * [`g:xray_trail_char`](#gxray_trail_char)
  * [`g:xray_verbose`](#gxray_verbose)
* [Commands](#commands)
  * [`:XrayToggle`](#xraytoggle)
* [Bugs](#bugs)
* [FAQ](#faq)
* [License](#license)
* [Contributing](#contributing)
* [Changelog](#changelog)


Introduction
------------

This plugin attempts to emulate a feature found in other text editors
such as [Sublime Text] which reveals whitespace only when it's selected.
It is a bit like setting some of the values of the [`listchars`] option
on the fly for visual selections only.


### How Does It Work? ###

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

This plugin also abuses highlighting and the [`listchars`]
functionality. Behind the scenes, it swaps the [`listchars`] out while
in Visual mode, and it changes the way they look so that they blend into
the background unless they're selected.


Status
------

This plugin should be considered beta-status. This means it'll probably
work if you meet the requirements, but not everything is finished, and
it might break.

Currently, it implements spaces, tabs, ends of lines, and trailing
whitespace.


Requirements
------------

This plugin requires a version of Vim of 7.4.1154 or greater. Vim must
be compiled with the [`visual`] (always included since version 7.4.200),
[`syntax`], [`autocmd`], and [`timers`] features. Check the output from
"`vim --version`" or "`:version`" if you're unsure, but most Vim builds
include these.

Not every terminal emulator works. Most common, modern ones I've tested
with do. If you install the plugin and nothing happens, see the
[FAQ](#faq) for troubleshooting.

Finally, the colorscheme for Vim must be set to one which sets the
background color for the "Normal" highlight group. Most do, but the
"default" colorscheme does not. If you're unsure, use this command to
see what your "Normal" says.

    :hi Normal

If you see words like "`ctermbg`" and "`guibg`" in there somewhere, then
you're set. If in doubt, just try the plugin out. If nothing happens,
see the [FAQ](#faq) for troubleshooting.


Installing
----------

This plugin may be installed any of the usual ways. Below are the
suggested ways for [Pathogen] and Vim 8's own built-in package method.


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


Usage
-----

This plugin takes effect upon installation. To see it in action, select
some text. Look at the example GIF supplied to see how it could appear.

If you want to customize it, look at the [configuration](#configuration)
section below.


Configuration
-------------

Settings below configure vim-xray. Each setting takes effect immediately
(or upon a mode change) unless otherwise noted. All settings are shown
with their defaults.


### `g:xray_enable` ###

Globally enables or disables all functionality.

    let g:xray_enable = 1

If it's set to 0 when Vim starts, then the plugin never enables
entirely, as if it had been toggled off. To enable the plugin, it's not
enough to set this value to 1 -- you need to use
[`XrayToggle`](#xraytoggle) to get things moving.

If you set it after Vim has started, it has the effect of temporarily
nullifying the effect of the plugin without altogether disabling it. It
does not prevent the timer from firing. To do that, you need to toggle
the plugin off using [`XrayToggle`](#xraytoggle).


### `g:xray_force_redraw` ###

Forces Vim to redraw the screen when entering or leaving Visual mode.

    let g:xray_force_redraw = 1


### `g:xray_allowed_filetypes` ###

List of filetypes for which the plugin is allowed.

    let g:xray_allowed_filetypes = []

**NOTE**: If this is set to a non-empty value, it signifies that xray
should work _only_ for the supplied filetypes. This overrides
[`g:xray_ignored_filetypes`](#gxray_ignored_filetypes) as well.


### `g:xray_ignored_filetypes` ###

List of filetypes for which the plugin is disabled.

    let g:xray_ignored_filetypes = ['qf', 'nerdtree', 'tagbar']

Not used if [`g:xray_allowed_filetypes`](#gxray_allowed_filetypes) is
non-empty.


### `g:xray_refresh_interval` ###

How often, in milliseconds, to check which mode the user is in.

    let g:xray_refresh_interval = 100

Smaller values appear more natural but waste more processing time.
Larger values are more efficient but may look glitchy for a moment when
leaving or entering Visual mode.


### `g:xray_space_char` ###

The character to display in place of a single space in a visual
selection. Behavior is the same as that for [`lcs-space`].

    let g:xray_space_char = '·'


### `g:xray_tab_chars` ###

The characters to display in place of a single tab in a visual
selection. Behavior is the same as that for [`lcs-tab`].

    let g:xray_tab_chars = '› '


### `g:xray_eol_char` ###

The character to display in place of a linebreak in a visual selection.
Behavior is the same as that for [`lcs-eol`].

    let g:xray_eol_char = '¶'


### `g:xray_trail_char` ###

The character to display in place of a trailing space in a visual
selection. Behavior is the same as that for [`lcs-trail`]. **Note**
especially that this character overrides the appearance of a space for
trailing spaces.

    let g:xray_trail_char = '·'


### `g:xray_verbose` ###

Enable printing some extra details, such as error messages.

    let g:xray_verbose = 0


Commands
--------

These commands are available for controlling the plugin's behavior.


### `:XrayToggle` ###

The plugin may be entirely enabled or disabled by using the command
XrayToggle. This stops the refresh timer, so in that way, it is
different than [`g:xray_enable`](#gxray_enable).

    :XrayToggle


Bugs
----

* If a colorscheme does not set the background color for Normal, this
  plugin cannot work and does nothing. (For example, the "default"
  colorscheme.)
* This plugin assumes the colorscheme does not change during a Vim
  session. It glitches if it does.
* Some terminals are not detected properly nor supported (e.g., urxvt).
* Sometimes Vim wrongly guesses the background color, causing
  [`listchars`] to show up outside of a visual selection.
* At this time, it's not possible to configure the color of the
  [`listchars`] shown in a visual selection due to the hack used to make
  them hide against the background outside of that selection.
  * This could be addressed in a future version using some syntax
    trickery.


FAQ
---

Below are some questions that you might have while trying to use
vim-xray. Many of these are due to [bugs](#bugs) or weird gotchas due to
[the implementation](#how-does-it-work).


### Why doesn't anything happen when I select stuff? ###

vim-xray checks a few things before attempting to draw whitespace during
Visual mode. It's likely one of these checks failed. You can tell if one
of these checks failed yourself by running this command.

    :echo xray#highlight#CanSetHighlight()

If that command prints `v:false`, you can check a few things.

* Are you using a terminal without colors at all? I don't know how to
  support those.
* Are you using a more unusual terminal, like rxvt, the Linux console,
  the original xterm, or some such? I found that there were drawing bugs
  and have limited support for those. I can't list all the supported
  terminals for sure because I don't know them all, but I've tested on
  several. If you're using one of these, and you believe I should
  support it, let me know.
* Is the environment variable `$TERM` not set? Is it set to an unusual
  value? If either of these are the case, this could be causing either
  my plugin or Vim to have trouble detecting your terminal capabilities.
* Are you using the "default" colorscheme? Vim is unable to detect the
  background color in that case because it's not set. You can either
  switch colorschemes, or you can manually set the background to the
  same as for your terminal with something like the following in your
  "$HOME/.vimrc".

      hi Normal ctermbg=0

If that command printed `v:true`, something else is amiss. You can
set [`g:xray_verbose`](#gxray_verbose) to `1` or `v:true`, and you'll
see if an error prints out at the bottom of the screen when vim-xray
tries to draw whitespace in Visual mode.


### Why do I see whitespace outside of the selection in Visual mode? ###

This isn't intended. This is a bug. You're welcome to tell me about it,
but I'm not sure I'll be able to do anything but disable support for
your terminal.


### I switched colorschemes, and now I see whitespace outside of selections. ###

That's not a question, but I see your point. The problem is, my plugin
assumes you will not change your colorscheme at runtime.

Vim detects your background color from the "Normal" highlight group once
and only once. It seems to expect you won't change it again. I could
attempt to parse it out every time I need to set up for Visual mode, but
that's error-prone. It optimizes for a corner-case that really isn't
worthwhile.

If you want to change your colorscheme, close and reopen Vim for
vim-xray to look right again. Otherwise, [toggle it off](#xraytoggle)
for the time being.


### I'm seeing my whitespace even outside of Visual mode. Now what? ###

Yeah, this is a bug. I'm sorry about that. This is likely some state
that has gotten messed up inadvertently. (Event-driven concurrency is
hard.) Restarting Vim should fix it up. If you are able to cause this to
happen through an easy-to-reproduce process, let me know.


License
-------

Released into the public domain (CC0 license). For details, see:
https://creativecommons.org/publicdomain/zero/1.0/legalcode



Contributing
------------

To contribute to this plugin, find it on GitHub. Please see the
[CONTRIBUTING](CONTRIBUTING.markdown) file accompanying it for
guidelines.

https://github.com/emilyst/vim-xray


Changelog
---------

* 2018-11-22
  * Detect Visual mode using built-in function
* 2018-10-21
  * Fixed some bugs on non-truecolor terminals
  * Added some performance improvements
  * Added a verbose setting ([`g:xray_verbose`](#gxray_verbose))
  * Improve the FAQ
  * Update status
  * Explicitly note requirements
* 2018-10-18
  * Improved highlighting detection corner-cases
  * Added FAQ
* 2018-10-16
  * Fixed and harmonized documentation
* 2018-10-15
  * Add XrayToggle command
* 2018-10-15
  * Initial release


[`listchars`]:  http://vimhelp.appspot.com/options.txt.html#%27listchars%27
[`visual`]:     http://vimhelp.appspot.com/visual.txt.html
[`syntax`]:     http://vimhelp.appspot.com/syntax.txt.html
[`autocmd`]:    http://vimhelp.appspot.com/autocmd.txt.html
[`timers`]:     http://vimhelp.appspot.com/eval.txt.html#timers
[Steve Losh]:   http://learnvimscriptthehardway.stevelosh.com
[Sublime Text]: https://www.sublimetext.com
[example]:      example.gif
[Pathogen]:     https://github.com/tpope/vim-pathogen
[`lcs-space`]:  http://vimhelp.appspot.com/options.txt.html#lcs-space
[`lcs-tab`]:    http://vimhelp.appspot.com/options.txt.html#lcs-tab
[`lcs-eol`]:    http://vimhelp.appspot.com/options.txt.html#lcs-eol
[`lcs-trail`]:  http://vimhelp.appspot.com/options.txt.html#lcs-trail
