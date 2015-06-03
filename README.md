# Wildstar "Armory" project ##
[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/ws-armory/Armory/~chat)

## Summary ##
* [Overview](#overview)
* [Developer Notes](#developer-notes)
  * [How does it work](#how-does-it-work)
  * [Technical details](#technical-details)
  * [The website](#the-website)
* [Contact](#contact)

## Overview ##

The main idea of this project is to provide a way for [Wildstar](http://wildstar-online.com/) players to share a link to their equipment (to post it on forums or in a guide for example).

The [website](http://ws-armory.github.io/) is used for two things: visualize the equipments and get a short link for sharing purpose.

It is possible to get a link to your equipment in-game using the [Armory addon](http://http://curse.com/project/225711) for Wildstar. It is also possible to build your own list ([more](https://github.com/ws-armory/ws-armory.github.io#building-custom-lists)).


## Developer Notes ##

### How does it work ###

Wildstar in-game API exposes unique _#_ to reference each objects, information about this objects can be found in different online databases such as [Jabbithole](http://www.jabbithole.com).

This addon gather couples of (_slot_id_, _item_id_) then generates a link to the website based on this couples.

Information about items are then gathered by the website using the [Jabbithole](http://www.jabbithole.com) online database ([more details](https://github.com/ws-armory/ws-armory.github.io) about the website internals).


### Technical details ###

The addon is really simple, it's work only rely on three functions of the `GameLib` API: `PlayerUnit:GetEquippedItems()`, `Item:GetSlot()` and `Item:GetItemId()`.

It pretty much looks like as:

```lua
var url = InitUrl()

for key, item in ipairs(GameLib.GetPlayerUnit():GetEquippedItems()) do
	AddItemToUrl(url,item:GetSlot(), item:GetItemId())
end

--- generated links are looking like:
--- http://ws-armory.github.io/?0=17830&1=13449&4=13329&5=30459&7=28056&10=28012

CopyUrlToClipboard(url)
```

That's all, as said before, really simple !


### The website ###

More details about the website internals can be found on it's [dedicated webpage](https://github.com/ws-armory/ws-armory.github.io).


## Contact ##
* [Curse project's page](http://www.curse.com/ws-addons/wildstar/225711-armory)
* [Armory chat room](https://gitter.im/ws-armory/chat/~chat)
* [Wildstar addon chat room](https://gitter.im/ws-armory/Armory/~chat)
* [Bug report and Feature request](https://github.com/ws-armory/Armory/issues)
* [Private message](https://github.com/olbat)
