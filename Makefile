##
## Makefile
##
## Made by Christopher Zorn <tofu@thetofu.com>
##
## Started on  Mon Nov  2 16:50:29 2009 Christopher Zorn
## Last update Mon Nov  2 16:50:29 2009 Christopher Zorn
##

#####################
# Macro Definitions #
#####################
ERL	= erl
ERLC	= erlc
MAKE	= make
SHELL	= /bin/sh
RM	= /bin/rm -rf


##############################
# Basic Compile Instructions #
##############################

all: thrift
	rebar compile

thrift: include/scribe_thrift.hrl src/scribe_thrift.erl

include/scribe_thrift.hrl: scribe.thrift
	thrift --gen erl scribe.thrift
	mv -f gen-erl/*.hrl include/

src/scribe_thrift.erl: scribe.thrift
	thrift --gen erl scribe.thrift
	mv -f gen-erl/*.erl src/

ungen:
	-$(RM) gen-erl
	-$(RM) include/*.hrl


clean:
	rebar clean
