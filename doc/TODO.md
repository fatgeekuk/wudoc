# Wudoc::Configuration

# Wudoc

Extract out the document producer from the base class.


# Wudoc::Traverser

Get it to produce a file specific config object for each file being parsed to include file specific
config from the tree hierarchy, so we can have centralised file pragmas.

# Wudoc::Producer (new class)

Generate HTML based html:// rather than File:// based.
Generate npm config file with integrated 'serve' command

# Wudoc::Configuration

Add tests for missing 'tree' section

Add default configuration to base, so that we can then override documentation location etc.

# Wudoc::Documenters::Ruby

Add documentation of the output option.

# Wudoc::Messages (new class)

Logger receiver with output needs to be added, and to be used by Configuration object to report
malformed config files. 

# Start Dogfooding. 

Use wudoc to document wudoc.

