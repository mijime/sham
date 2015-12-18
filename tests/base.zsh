#!/usr/bin/zsh -e

TEST_TARGET=${TEST_TARGET:-.*}
cdir=$(cd $(dirname $0);pwd)

include_files() {
  cat <<EOF
  TEST_CASE=zsh
  SHELL=/usr/bin/zsh

  export DEPLUG_HOME=/tmp/tests/zsh
  export DEPLUG_BIN=/tmp/tests/zsh/bin
  export DEPLUG_CACHE=/tmp/tests/zsh/cache
  export DEPLUG_STATE=/tmp/tests/zsh/state
  export DEPLUG_REPO=/tmp/tests/zsh/repos
EOF
  cat ${cdir}/../src/*.sh ${cdir}/../src/*.zsh
  cat ${cdir}/utils/*.sh
  ls -1p ${cdir}/cases/*.sh | grep "${TEST_TARGET}" | xargs cat
}

include_files | zsh ${TEST_OPTIONS}
