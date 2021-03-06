TEST_OPTIONS=
TARGET=dist/sham.sh
SRC_TARGET=$(wildcard src/*/*.sh) src/sham.sh
TEST_TARGET=$(wildcard test/*/*.sh)

all: $(TARGET)

$(TARGET): $(SRC_TARGET)
	find $^ -type f | LC_ALL=C sort -n | xargs cat > $@

test: $(TEST_TARGET)

test/%.sh: $(TARGET)
	dist/unitesh.sh $@

docker/%/build: docker/%
	docker build --tag=sham:$* $<

docker/%/test: docker/%/build $(TARGET)
	docker run --rm --volume /$$(pwd)://w --workdir //w sham:$* dist/unitesh.sh $(TEST_TARGET)

docker: docker/bash-3.0/test docker/bash-4.0/test docker/bash/test docker/zsh/test
