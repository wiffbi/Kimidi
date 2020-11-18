Kimidi – keyboard shortcuts to MIDI
===================================

This is [Matatata's](https://github.com/matatatata) fork of the accompanying [Kimidi app](https://github.com/wiffbi/Kimidi) for Selected_Track_Control for Ableton Live. On OS X, this app transforms global keyboard shortcuts into MIDI messages, which are sent to Ableton Live on a virtual MIDI-port (created by the app automatically itself). **This allows instant keyboard-control of lots of features in Ableton Live** that either would require prior, manual configuration of each Live-set or aren't possible at all (such as using the same keyboard shortcut for e.g. the mute button – but always on the selected track).

More information and the app itself can be found on the [project’s homepage.](http://stc.wiffbi.com/)

# About the fork
The original version will most likely NOT work under macOS 10.15 Catalina because Apple deprecated the Carbon API. In this fork I tried to remove that dependency and as a consequence had to make several changes to make it work without the Carbon API.

Current version is 1.3.2 and it seems to work fine on Mojave and Catalina. I've created a binary release https://github.com/matatata/Kimidi/releases/tag/1.3.2 for it. I hope it'll work for you. Note that 1.3.0 contained PYMIDI with a code signature not suitable for distribution. Maybe it cause problems for you, so please try 1.3.2.

To build the app, we'll clone this repository and the [PYMIDI.framework](https://github.com/matatata/pymidi.git) submodule by executing these commands:

	git clone https://github.com/matatata/Kimidi.git Kimidi
	cd Kimidi
	git submodule init
	git submodule update --remote
	
Then we'll build the submodule and finally Kimidi

	cd externals/pymidi
	xcodebuild
	cd ../..
	xcodebuild
	
	open build/Release
	
Upon first start you'll be asked to allow the app to use accessibility features. This is indeed necessary in order to allow the app to receive key strokes from Ableton Live. If the app has not permission - it will not work and not receive keystrokes, so please check that the app is listed in `System Preferences/Security & Privacy` Tab `Privacy` section `Accessibility`. If you had a previous version of Kimidi installed, you might need to remove it from that list and add the new app again.



	
	






