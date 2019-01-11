FROM ruby:2.3 as assets

# Install gem bundle
ADD Gemfile /app/
ADD Gemfile.lock /app/
WORKDIR /app
RUN bundle install --jobs 3 --without development test

# Install the application
ADD . /app

# Install nodejs
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs

# Precompile assets
RUN bundle exec rake assets:precompile RAILS_ENV=production SECRET_KEY_BASE=secret

FROM ruby:2.3

# Install gem bundle
ADD Gemfile /app/
ADD Gemfile.lock /app/
WORKDIR /app
RUN bundle install --jobs 3 --without development test

# Install the application
ADD . /app

# Install extra files
ADD docker/migrate       /app/migrate
ADD docker/database.yml  /app/config/database.yml

# Copy assets
COPY --from=assets /app/public/assets /app/public/assets

ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_ENV=production
ENV BIND=tcp://0.0.0.0:80
ENV PUMA_TAG=guisso
ENV PUMA_PARAMS=
EXPOSE 80

CMD exec puma -e $RAILS_ENV -b $BIND --tag $PUMA_TAG $PUMA_PARAMS
