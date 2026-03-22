.PHONY: build server upload

build:
	yarn build
	hugo build --cleanDestinationDir

server:
	hugo server

upload:
	yarn build
	hugo build --cleanDestinationDir
	rsync -avz --delete --progress public/ dh_eckgii@pdx1-shared-a1-28.dreamhost.com:/home/dh_eckgii/sheerio.online/
