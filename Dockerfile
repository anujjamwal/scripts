FROM manjarolinux/base

ENV TERM=xterm-256color

RUN pacman -Syu --noconfirm
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN source $HOME/.cargo/env; rustup component add rls rust-analysis rust-src

RUN pacman -S --noconfirm emacs git valgrind clang jdk8-openjdk

COPY emacs /root/.emacs.d
RUN emacs --daemon

ENV PATH="/root/.cargo/bin:${PATH}"

