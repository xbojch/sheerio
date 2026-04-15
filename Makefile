.PHONY: build server upload next

build:
	yarn build
	hugo build --cleanDestinationDir

server:
	hugo server

upload:
	yarn build
	hugo build --cleanDestinationDir
	rsync -avz --delete --progress public/ dh_eckgii@pdx1-shared-a1-28.dreamhost.com:/home/dh_eckgii/sheerio.online/

next:
	YOUTUBE_TOKEN=$$(./scripts/oauth2l fetch --credentials scripts/client_secret_442268207105-l7gk3qpdv92it4ns4ua6q7pb09pcdbnl.apps.googleusercontent.com.json --scope youtube.readonly 2>/dev/null || ./scripts/oauth2l fetch --credentials scripts/client_secret_442268207105-l7gk3qpdv92it4ns4ua6q7pb09pcdbnl.apps.googleusercontent.com.json --scope youtube.readonly) ./scripts/next-from-playlist.sh
