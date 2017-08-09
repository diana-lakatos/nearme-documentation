FROM ruby:2.3.1

ENV APP_HOME /usr/app
ENV BUILD_PACKAGES build-essential bash curl vim
ENV RUBY_THREAD_VM_STACK_SIZE 5000000

RUN apt-get update -qq && \
    apt-get install -y $BUILD_PACKAGES --force-yes && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir $APP_HOME && \
    mkdir $APP_HOME/tmp && \
    mkdir $APP_HOME/log && \
    gem install yard --no-ri --no-rdoc

WORKDIR $APP_HOME

ADD .yard ./.yard

ADD lib/liquid/filters/platform_filters.rb lib/liquid/filters/platform_filters.rb
ADD app/liquid_tags/ app/liquid_tags/
ADD app/forms/ app/forms/

RUN yard --one-file -p .yard/frontend_template/ -o doc/liquid/ --hide-tag todo --markup markdown lib/liquid/**/*
RUN yard --one-file -p .yard/frontend_template/ -o doc/liquid_tags/ --hide-tag todo --markup markdown app/liquid_tags/**
RUN yard --one-file -p .yard/frontend_template/ -o doc/forms/ --hide-tag todo --markup markdown app/forms/**

EXPOSE 8000

CMD ["python", "-m", "SimpleHTTPServer"]
