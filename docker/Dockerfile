FROM ruby:slim-buster
MAINTAINER Steve Miller <me@r15cookie.com>
RUN gem install civo_cli
RUN useradd -m user
USER user
ENTRYPOINT ["civo"]
