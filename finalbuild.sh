#!/bin/sh
echo "Deleting old publication"
  rm -rf public
	mkdir public

	echo "Generating site"
	hugo
	echo "Add gzip files to speed site delivery"
	find public/ -type f  -name "*.html" -exec gzip -kf {} \;
	find public/ -type f  -name "*.xml" -exec gzip -kf {} \;
	find public/ -type f  -name "*.txt" -exec gzip -kf {} \;
	find public/ -type f  -name "*.pdf" -exec gzip -kf {} \;
	find public/ -type f  -name "*.ico" -exec gzip -kf {} \;
  exit 0
	