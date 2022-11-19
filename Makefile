.PHONY: build run

# Default values for variables
REPO  ?= $${USER}_ubuntu_desktop_vnc
TAG   ?= latest
# you can choose other base image versions
IMAGE ?= ubuntu:20.04
# IMAGE ?= nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
# choose from supported flavors (see available ones in ./flavors/*.yml)
FLAVOR ?= lxde
# armhf or amd64
ARCH ?= amd64
PASSWORD ?= password
PWD=$(shell pwd)

# These files will be generated from teh Jinja templates (.j2 sources)
templates = rootfs/etc/supervisor/conf.d/supervisord.conf

# Rebuild the container image
build: $(templates)
	time docker build -t $(REPO):$(TAG) .

# Test run the container
# the local dir will be mounted under /src read-only
run:
	docker run --rm \
		-p 6080:80 -p 6081:443 -p 10022:10022 \
		-e USER=${USER} \
		-e PASSWORD=${PASSWORD} \
		-e HTTP_PASSWORD=${PASSWORD} \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/group:/etc/group:ro \
		-v $(shell pwd):/home/${USER}/tmp \
		-v $(shell pwd)/workspace:/home/${USER}/workspace\
		--name ubuntu-desktop-lxde-test \
		--gpus all \
		$(REPO):$(TAG)

		#-v ${PWD}:/src:ro \
		#-e ALSADEV=hw:2,0 
		#-e SSL_PORT=443 
		#-e RELATIVE_URL_ROOT=approot 
		#-e OPENBOX_ARGS="--startup /usr/bin/galculator"
		#-v ${PWD}/ssl:/etc/nginx/ssl 
		#--device /dev/snd 

install_deps:
	time ./install_deps.sh ${USER}
	
# Connect inside the running container for debugging
shell:
	docker exec -it ubuntu-desktop-lxde-test bash

# Generate the SSL/TLS config for HTTPS
gen-ssl:
	mkdir -p ssl
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout ssl/nginx.key -out ssl/nginx.crt

clean:
	rm -f $(templates)

extra-clean:
	docker rmi $(REPO):$(TAG)
	docker image prune -f

# Run jinja2cli to parse Jinja template applying rules defined in the flavors definitions
%: %.j2 flavors/$(FLAVOR).yml
	docker run -v $(shell pwd):/data vikingco/jinja2cli \
		-D flavor=$(FLAVOR) \
		-D image=$(IMAGE) \
		-D localbuild=$(LOCALBUILD) \
		-D arch=$(ARCH) \
		$< flavors/$(FLAVOR).yml > $@ || rm $@
