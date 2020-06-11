#!/bin/bash
for dir in *
do
	if [[ -d $dir ]] ; then
		zip $dir.zip $dir/*
	fi
done
zip jastest_csm.zip `ls */* -d`
