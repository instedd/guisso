FROM ruby:2.3-alpine as build

# Install gem bundle
ADD Gemfile /app/
ADD Gemfile.lock /app/
WORKDIR /app

# Install required packages
RUN apk add --no-cache build-base nodejs git mysql-dev postgresql-dev tzdata

# Install gems
RUN bundle install --jobs 10 --without development test

# Install the application
ADD . /app

# Precompile assets
RUN bundle exec rake assets:precompile RAILS_ENV=production SECRET_KEY_BASE=secret

FROM ruby:2.3-alpine

# Install gem bundle
ADD Gemfile /app/
ADD Gemfile.lock /app/
WORKDIR /app

# Install required packages
RUN apk add --no-cache tzdata libpq mariadb-connector-c

# Install the application
ADD . /app

# Install extra files
ADD docker/migrate       /app/migrate
ADD docker/database.yml  /app/config/database.yml

# Copy bundle and assets
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app/public/assets /app/public/assets

ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_ENV=production
ENV BIND=tcp://0.0.0.0:80
ENV PUMA_TAG=guisso
ENV PUMA_PARAMS=
EXPOSE 80

CMD exec puma -e $RAILS_ENV -b $BIND --tag $PUMA_TAG $PUMA_PARAMS
