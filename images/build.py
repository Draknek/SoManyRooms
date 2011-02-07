#!/usr/bin/python

import os
import sys

def run (command):
	print command
	
	ret = os.system(command)
	
	if (ret):
		sys.exit(ret)

input = open('images.txt')

embed = ""

for line in input:
	parts = line.strip().split(" ")
	
	filename = parts[0]
	quality = parts[1]
	alpha = "normal"
	
	if (len(parts) > 2):
		alpha = parts[2]
	
	if (quality == 'nojpg'):
		embed += '[Embed(source="images/orig/' + filename + '.png")] public static var ' + filename.replace('-', '_') + 'ALPHA:Class;\n'
	else:
		run('convert -quality ' + quality + ' orig/' + filename + '.png jpg/' + filename + '.jpg');
		embed += '[Embed(source="images/jpg/' + filename + '.jpg")] public static var ' + filename.replace('-', '_') + 'JPG:Class;\n'
		
		if (alpha != 'noalpha'):
			run('convert -alpha extract orig/' + filename + '.png alpha/' + filename + '.png');
			embed += '[Embed(source="images/alpha/' + filename + '.png")] public static var ' + filename.replace('-', '_') + 'ALPHA:Class;\n'
	
input.close()

input = open('Assets.as.orig')

sourcecode = input.read()

input.close()

sourcecode = sourcecode.replace('!!! ASSETS GO HERE !!!', embed)

output = open('../Assets.as', 'w')

output.write(sourcecode)

output.close()


