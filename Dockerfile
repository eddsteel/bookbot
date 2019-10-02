FROM fpco/stack-build:lts-10.10 as build
RUN mkdir /opt/build
COPY . /opt/build
RUN cd /opt/build && stack build --system-ghc
FROM ubuntu:18.10
RUN mkdir -p /opt/bookbot
WORKDIR /opt/bookbot
RUN apt-get update && apt-get install -y \
  ca-certificates \
  libgmp-dev \
  netbase
COPY --from=build /opt/build/.stack-work/install/x86_64-linux/lts-10.10/8.2.2/bin/ .
CMD ["/opt/bookbot/post"]
