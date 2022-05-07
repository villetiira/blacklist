# blacklist

This is a PowerShell script, which I created for a gaming community I was in. The purpose of the script was to make it easier to keep track of players, who've been known to cause issues in the past, either by being impolite, stealing or similar unwanted behavior. We had already setup a Google Sheets, which was updated by people in the community, but it was cumbersome to cross-reference when the list got longer.

As a solution, I wrote this script, which would bring the data into the game itself. When the script was run, it fetched the data from the sheets, parsed through it and formatted it into a .lua file. This file was then read by a pre-existing addon in the game, which alerted the player whenever they received a message or an invitation from one of the players in the list.
