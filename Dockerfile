# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
# Update default packages
RUN apt-get update -y

# Get Ubuntu packages
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl build-essential clang

RUN curl -OL https://golang.org/dl/go1.18.2.linux-amd64.tar.gz

RUN ls
ENV GOROOT=/usr/local/go

RUN rm -rf $GOROOT && tar -C /usr/local -xzf go1.18.2.linux-amd64.tar.gz

ENV GOPATH=/go
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /carvel-imgpkg
WORKDIR /carvel-imgpkg

RUN go install github.com/dvyukov/go-fuzz/go-fuzz@latest github.com/dvyukov/go-fuzz/go-fuzz-build@latest

# RUN go get -d github.com/dvyukov/go-fuzz-corpus

# TODO figure this step out
RUN go-fuzz-build -libfuzzer -o gif.a .

RUN clang -fsanitize=fuzzer git.a -o fuzz_gif