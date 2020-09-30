# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

VERSIONFILE := pkg/util/defaults/defaults.go
VERSION := 0.1.0-SNAPSHOT
LAST_RELEASED_VERSION := 0.1.0
LOCAL_REPOSITORY := /tmp/artifacts/m2
IMAGE_NAME := docker.io/yaks/yaks
RELEASE_GIT_REMOTE := upstream
GIT_COMMIT := $(shell git rev-list -1 HEAD)

# OLM (Operator Lifecycle Manager and Operator Hub): uncomment to override operator settings at build time
#GOLDFLAGS += -X github.com/citrusframework/yaks/pkg/util/olm.DefaultOperatorName=yaks-operator
#GOLDFLAGS += -X github.com/citrusframework/yaks/pkg/util/olm.DefaultPackage=yaks
#GOLDFLAGS += -X github.com/citrusframework/yaks/pkg/util/olm.DefaultChannel=alpha
#GOLDFLAGS += -X github.com/citrusframework/yaks/pkg/util/olm.DefaultSource=community-operators
#GOLDFLAGS += -X github.com/citrusframework/yaks/pkg/util/olm.DefaultSourceNamespace=openshift-marketplace
#GOLDFLAGS += -X github.com/citrusframework/yaks/pkg/util/olm.DefaultStartingCSV=
#GOLDFLAGS += -X github.com/citrusframework/yaks/pkg/util/olm.DefaultGlobalNamespace=openshift-operators

GOLDFLAGS += -X main.GitCommit=$(GIT_COMMIT)
GOFLAGS = -ldflags "$(GOLDFLAGS)" -gcflags=-trimpath=$(GO_PATH) -asmflags=-trimpath=$(GO_PATH)

define LICENSE_HEADER
Licensed to the Apache Software Foundation (ASF) under one or more
contributor license agreements.  See the NOTICE file distributed with
this work for additional information regarding copyright ownership.
The ASF licenses this file to You under the Apache License, Version 2.0
(the "License"); you may not use this file except in compliance with
the License.  You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
endef

export LICENSE_HEADER
default: test

#
# Generates the version file
#
codegen:
	@echo "/*" > $(VERSIONFILE)
	@echo "$$LICENSE_HEADER" >> $(VERSIONFILE)
	@echo "*/" >> $(VERSIONFILE)
	@echo "" >> $(VERSIONFILE)
	@echo "package defaults" >> $(VERSIONFILE)
	@echo "" >> $(VERSIONFILE)
	@echo "// ***********************" >> $(VERSIONFILE)
	@echo "//  DO NOT EDIT THIS FILE"  >> $(VERSIONFILE)
	@echo "// ***********************" >> $(VERSIONFILE)
	@echo "" >> $(VERSIONFILE)
	@echo "const (" >> $(VERSIONFILE)
	@echo "  // Version -- " >> $(VERSIONFILE)
	@echo "  Version = \"$(VERSION)\"" >> $(VERSIONFILE)
	@echo "" >> $(VERSIONFILE)
	@echo "  // LocalRepository -- " >> $(VERSIONFILE)
	@echo "  LocalRepository = \"$(LOCAL_REPOSITORY)\"" >> $(VERSIONFILE)
	@echo "" >> $(VERSIONFILE)
	@echo "  // ImageName -- " >> $(VERSIONFILE)
	@echo "  ImageName = \"$(IMAGE_NAME)\"" >> $(VERSIONFILE)
	@echo ")" >> $(VERSIONFILE)
	@echo "" >> $(VERSIONFILE)
	gofmt -w pkg/util/defaults/defaults.go

clean:
	./script/clean.sh

check-licenses:
	./script/check_licenses.sh

generate: generate-deepcopy generate-crd generate-client

generate-client:
	./script/gen_client.sh

generate-crd:
	./script/gen_crd.sh

generate-deepcopy:
	operator-sdk generate k8s

build: build-resources build-yaks

test: build
	go test ./...

build-yaks:
	go build $(GOFLAGS) -o yaks ./cmd/manager/*.go

build-resources:
	./script/embed_resources.sh deploy

build-olm:
	./script/build_olm.sh $(VERSION)

set-version:
	./script/set_version.sh $(VERSION) $(IMAGE_NAME)

set-next-snapshot:
	./script/next_snapshot.sh

git-tag:
	./script/git_tag.sh $(VERSION) $(RELEASE_GIT_REMOTE)

cross-compile:
	./script/cross_compile.sh $(VERSION) '$(GOFLAGS)'

docker-image:
	mkdir -p build/_output/bin
	operator-sdk build --image-builder docker $(IMAGE_NAME):$(VERSION)

images-no-test: build package-artifacts-no-test docker-image

images: test package-artifacts docker-image

images-push:
	docker push $(IMAGE_NAME):$(VERSION)

prepare-release: clean codegen set-version check-licenses unsnapshot-olm unsnapshot-sources cross-compile

release: prepare-release images images-push git-tag

release-snapshot: clean codegen set-version cross-compile images images-push

package-artifacts-no-test:
	./script/package_maven_artifacts.sh -DskipTests

package-artifacts:
	./script/package_maven_artifacts.sh

unsnapshot-olm:
	./script/unsnapshot_olm.sh

unsnapshot-sources:
	./script/unsnapshot_sources.sh

version:
	@echo $(VERSION)

.PHONY: clean build build-yaks build-resources build-olm unsnapshot-olm unsnapshot-sources codegen cross-compile test docker-image images images-no-test images-push package-artifacts package-artifacts-no-test release release-snapshot set-version git-tag check-licenses version
