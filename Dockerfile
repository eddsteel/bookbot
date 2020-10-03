# Thanks https://medium.com/permutive/optimized-docker-builds-for-haskell-76a9808eb10b

FROM fpco/stack-build:lts-10.10 as dependencies
RUN mkdir /opt/build
WORKDIR /opt/build
RUN apt-get update || apt-get install apt-transport-https ca-certificates
RUN apt-get update && apt-get download libgmp10
RUN mv libgmp*.deb libgmp.deb
COPY stack.yaml package.yaml stack.yaml.lock /opt/build/
RUN stack build --system-ghc --dependencies-only

#---

FROM fpco/stack-build:lts-10.10 as build
RUN mkdir /opt/build
COPY --from=dependencies /root/.stack /root/.stack
COPY . /opt/build
WORKDIR /opt/build
RUN stack build --system-ghc
RUN mv "$(stack path --local-install-root --system-ghc)/bin" /opt/build/bin

#---

FROM ubuntu:20.04 as app
RUN mkdir /opt/bookbot
WORKDIR /opt/bookbot
RUN apt-get update && apt-get install -y ca-certificates netbase librsvg2-common
COPY --from=dependencies /opt/build/libgmp.deb /tmp
RUN dpkg -i /tmp/libgmp.deb && rm /tmp/libgmp.deb
COPY --from=build /opt/build/bin/ .
CMD ["/opt/bookbot/post"]
