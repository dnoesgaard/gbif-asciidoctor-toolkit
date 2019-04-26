FROM alpine:3.9

LABEL MAINTAINERS="Guillaume Scheibel <guillaume.scheibel@gmail.com>, Damien DUPORTAL <damien.duportal@gmail.com>"

ARG asciidoctor_version=2.0.8
ARG asciidoctor_confluence_version=0.0.2
ARG asciidoctor_pdf_version=1.5.0.alpha.17
ARG asciidoctor_diagram_version=1.5.16
ARG asciidoctor_epub3_version=1.5.0.alpha.9
ARG asciidoctor_mathematical_version=0.3.0
ARG asciidoctor_revealjs_version=2.0.0

ENV ASCIIDOCTOR_VERSION=${asciidoctor_version} \
  ASCIIDOCTOR_CONFLUENCE_VERSION=${asciidoctor_confluence_version} \
  ASCIIDOCTOR_PDF_VERSION=${asciidoctor_pdf_version} \
  ASCIIDOCTOR_DIAGRAM_VERSION=${asciidoctor_diagram_version} \
  ASCIIDOCTOR_EPUB3_VERSION=${asciidoctor_epub3_version} \
  ASCIIDOCTOR_MATHEMATICAL_VERSION=${asciidoctor_mathematical_version} \
  ASCIIDOCTOR_REVEALJS_VERSION=${asciidoctor_revealjs_version}

# Installing package required for the runtime of
# any of the asciidoctor-* functionnalities
RUN apk add --no-cache \
    bash \
    curl \
    ca-certificates \
    findutils \
    font-bakoma-ttf \
    graphviz \
    inotify-tools \
    make \
    openjdk8-jre \
    py2-pillow \
    py-setuptools \
    python2 \
    ruby \
    ruby-mathematical \
    ttf-liberation \
    unzip \
    which

# Installing Ruby Gems needed in the image
# including asciidoctor itself
RUN apk add --no-cache --virtual .rubymakedepends \
    build-base \
    libxml2-dev \
    ruby-dev \
  && gem install --no-document \
    "asciidoctor:${ASCIIDOCTOR_VERSION}" \
    "asciidoctor-confluence:${ASCIIDOCTOR_CONFLUENCE_VERSION}" \
    "asciidoctor-diagram:${ASCIIDOCTOR_DIAGRAM_VERSION}" \
    "asciidoctor-epub3:${ASCIIDOCTOR_EPUB3_VERSION}" \
    "asciidoctor-mathematical:${ASCIIDOCTOR_MATHEMATICAL_VERSION}" \
    asciimath \
    "asciidoctor-pdf:${ASCIIDOCTOR_PDF_VERSION}" \
    "asciidoctor-revealjs:${ASCIIDOCTOR_REVEALJS_VERSION}" \
    coderay \
    epubcheck:3.0.1 \
    haml \
    kindlegen:3.0.3 \
    pygments.rb \
    rake \
    rouge \
    slim \
    thread_safe \
    tilt \
  && apk del -r --no-cache .rubymakedepends

# Installing Python dependencies for additional
# functionnalities as diagrams or syntax highligthing
RUN apk add --no-cache --virtual .pythonmakedepends \
    build-base \
    python2-dev \
    py2-pip \
  && pip install --upgrade pip \
  && pip install --no-cache-dir \
    actdiag \
    'blockdiag[pdf]' \
    nwdiag \
    Pygments \
    seqdiag \
  && apk del -r --no-cache .pythonmakedepends

# PO4A translation tool
RUN apk add --no-cache diffutils perl-unicode-linebreak po4a

# Git commit plugin
RUN apk add --no-cache openssl openssl-dev cmake ruby-dev ruby-rdoc gcc musl-dev
RUN gem install rugged

# A2S diagrams (needs Go)
#RUN apk add --no-cache git make musl-dev go
#ENV GOROOT /usr/lib/go
#ENV GOPATH /go
#ENV PATH /go/bin:$PATH
#RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin
#RUN apk add --no-cache go git gcc musl-dev
#go get github.com/asciitosvg/asciitosvg/cmd/a2s

# Stylesheet compiler:
#apk add ruby-rdoc ruby-bundler
#cd asciidoctor-stylesheet-factory/
#bundle install
#compass compile
#asciidoctor ... -a stylesheet=asciidoctor-stylesheet-factory/stylesheets/readthedocs.css

COPY asciidoctor-extensions-lab /adoc/asciidoctor-extensions-lab
COPY gbif-extensions/ /adoc/gbif-extensions/
COPY gbif-templates/ /adoc/gbif-templates/
COPY GbifHtmlConverter.rb /adoc/

# GBIF build script
RUN apk add --no-cache git
ENV PRIMARY_LANGUAGE=en
COPY build /usr/local/bin/build

WORKDIR /documents
VOLUME /documents

CMD ["/usr/local/bin/build"]
