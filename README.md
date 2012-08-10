NOTE: these instructions still need more work

Getting package selection from current install:

	dpkg --get-selections "*" > lophilo/debian/dpkg-get-selections

Creating wheezy image to Makefile:TARGET_DIR:

	make

Review, modify and use the mkcard.sh script to sync to the MicroSD card.
