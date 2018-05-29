FROM centos:7
MAINTAINER Shawn Johnson <sjohnso@gmail.com>

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin
ENV GOLANG_VERSION=1.10.2

RUN yum -y install deltarpm && \
    yum -y update && \
    yum -y install git sudo && \
    yum -y install ncurses-devel lua-devel ctags-etags gcc make && \
    ln -rsf /usr/share/zoneinfo/CST6CDT /etc/localtime && \
    cd /tmp && \
    git clone --branch v8.1.0026 https://github.com/vim/vim.git && \
    cd vim && \
    ./configure --with-features=huge --enable-luainterp --enable-gui=no --without-x --prefix=/usr/local && \
    make VIMRUNTIMEDIR=/usr/local/share/vim/vim81 && \
    make install && \
    cd /usr/bin && \
    mv vi vi.orig && \
    mv view view.orig && \
    ln -s ../local/bin/vim vi && \
    ln -s ../local/bin/vim vim && \
    ln -s ../local/bin/view && \
    yum -y remove cpp ctags ctags-etags gcc glibc-devel glibc-headers kernel-headers libgomp libmpc lua-devel make mpfr ncurses-devel && \
    rm -rf /var/cache/yum/* && \
    curl -o /tmp/go${GOLANG_VERSION}.linux-amd64.tar.gz https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    mkdir /usr/local/go${GOLANG_VERSION} && \
    tar zxpf /tmp/go${GOLANG_VERSION}.linux-amd64.tar.gz -C /usr/local/go${GOLANG_VERSION} --strip-components=1 && \
    rm -rf /tmp/go${GOLANG_VERSION}.linux-amd64.tar.gz /tmp/vim && \
    cd /usr/local && \
    ln -s go${GOLANG_VERSION} go && \
    cd /usr/local/bin && \
    ln -s ../go/bin/go && \
    export GOPATH=/tmp/go && \
    go get golang.org/x/tools/cmd/godoc && \
    go get github.com/nsf/gocode && \
    go get golang.org/x/tools/cmd/goimports && \
    go get github.com/rogpeppe/godef && \
    go get golang.org/x/tools/cmd/gorename && \
    go get github.com/golang/lint/golint && \
    go get github.com/kisielk/errcheck && \
    go get github.com/jstemmer/gotags && \
    go get github.com/tools/godep && \
    go get github.com/zmb3/gogetdoc && \
    go get golang.org/x/tools/cmd/guru && \
    go get github.com/davidrjenni/reftools/cmd/fillstruct && \
    go get github.com/fatih/motion && \
    go get github.com/josharian/impl && \
    go get github.com/fatih/gomodifytags && \
    go get github.com/dominikh/go-tools/cmd/keyify && \
    go get github.com/klauspost/asmfmt/cmd/asmfmt && \
    go get github.com/alecthomas/gometalinter && \
    /tmp/go/bin/gometalinter --install && \
    mv -f /tmp/go/bin/* /usr/local/go/bin && \
    rm -rf /tmp/go && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev && \
    chmod 0440 /etc/sudoers.d/dev && \
    useradd -s /bin/bash -d /home/dev -m dev && \
    mkdir -p /go/{bin,src} && \
    chown -R dev:dev /go

COPY files/run.sh /
COPY files/molokai.vim /home/dev/.vim/colors/
COPY files/dot-vimrc /home/dev/.vimrc
COPY files/plug.vim /home/dev/.vim/autoload/
RUN chmod +x /run.sh && \
    chown -R dev:dev /home/dev

USER dev
ENV HOME /home/dev
ENV GOPATH /go

RUN echo "export GOLANG_VERSION=${GOLANG_VERSION}" >> ${HOME}/.bashrc && \
    echo "export GOPATH=${GOPATH}" >> ${HOME}/.bashrc && \
    echo "export GOOS=linux" >> ${HOME}/.bashrc && \
    echo "export GOARCH=amd64" >> ${HOME}/.bashrc && \
    echo "cd /go" >> ${HOME}/.bashrc && \
    sed -i 's/^\(PATH=$PATH:\)\(.*\)/\1\/usr\/local\/go\/bin:\2/g' ${HOME}/.bash_profile
RUN vim +PlugInstall +qall

USER root

WORKDIR $GOPATH

CMD ["/run.sh"]
