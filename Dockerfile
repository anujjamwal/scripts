FROM archlinux

ENV TERM=xterm-256color

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm curl emacs git valgrind clang jdk8-openjdk

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN source $HOME/.cargo/env; rustup component add rls rust-analysis rust-src

COPY emacs /root/.emacs.d
RUN emacs --daemon

ENV PATH="/root/.cargo/bin:${PATH}"

