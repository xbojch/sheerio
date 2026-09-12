.SUFFIXES:

.PHONY: build rebuild server auth next delete

CREDENTIALS := scripts/client_secret_442268207105-l7gk3qpdv92it4ns4ua6q7pb09pcdbnl.apps.googleusercontent.com.json
TOKEN_FILE := scripts/.youtube_token

build:
	yarn build
	hugo build --cleanDestinationDir

rebuild:
	yarn build --force
	hugo build --cleanDestinationDir

server:
	hugo server

auth:
	@./scripts/oauth2l fetch --credentials $(CREDENTIALS) --scope youtube | grep '^ya29\.' > $(TOKEN_FILE)
	@echo "Authorized. Token saved to $(TOKEN_FILE)."

next:
	@video_id=$$(./scripts/next-from-playlist.sh) && \
		echo "$$video_id" && \
		claude "/add-video $$video_id"

delete:
ifndef ID
	$(error Usage: make delete ID=<youtube_video_id>)
endif
	@./scripts/delete-from-playlist.sh $(ID)
