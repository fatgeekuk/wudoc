# Items from the TODO list that get DONE will be placed in here in chronological order. Forming an adhoc release document.

## Early  Oct 2020

### Wudoc

Extract out the document producer from the base class. This ended up getting called Generators.

Initially there is one working generator (file_tree) and one none working one (web_tree)


### Wudoc::Traverser

Get it to produce a file specific config object for each file being parsed to include file specific
config from the tree hierarchy, so we can have centralised file pragmas.

### Start Dogfooding. 

Use wudoc to document wudoc.

## Start of project.

The code is a horrible mess, test coverage is almost non-existent. 