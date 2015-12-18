deplug --verbose reset
deplug --verbose list || true

deplug --verbose mijime/dat2bar  tag:master post:'notfoundfunc'
deplug --verbose list || true

deplug --verbose mijime/dotfiles post:'true' of:'.bashrc.d/*.sh' --use='.bin/*'
deplug --verbose list || true

deplug --verbose install
deplug --verbose list || true

deplug --verbose update
deplug --verbose list || true

deplug --verbose clean --yes
deplug --verbose list || true
