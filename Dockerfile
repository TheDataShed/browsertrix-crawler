FROM oldwebtoday/chrome:84 as chrome

FROM nikolaik/python-nodejs:python3.8-nodejs14

RUN apt-get update -y \
    && apt-get install --no-install-recommends -qqy fonts-stix locales-all \
    redis-server xvfb fonts-liberation libappindicator3-1 libasound2 \
    libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libcups2 libdbus-1-3 \
    libgbm1 libgtk-3-0 libnspr4 libnss3 libxcomposite1 libxcursor1 libxi6 \
    libxrandr2 libxtst6 xdg-utils apt-utils\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PROXY_HOST=localhost \
    PROXY_PORT=8080 \
    PROXY_CA_URL=http://wsgiprox/download/pem \
    PROXY_CA_FILE=/tmp/proxy-ca.pem \
    DISPLAY=:99 \
    GEOMETRY=1360x1020x16

RUN pip install git+https://github.com/TheDataShed/pywb@add_s3_uploader --use-feature=2020-resolver

RUN pip install uwsgi 'gevent==1.4.0' --use-feature=2020-resolver

COPY --from=chrome /tmp/*.deb /deb/
COPY --from=chrome /app/libpepflashplayer.so /app/libpepflashplayer.so
RUN dpkg -i /deb/*.deb; apt-get update; apt-get install -fqqy && \
    rm -rf /var/lib/opts/lists/*

WORKDIR /app

ADD package.json /app/

RUN yarn install

ADD config.yaml /app/
ADD uwsgi.ini /app/
ADD *.js /app/

RUN ln -s /app/main.js /usr/bin/crawl

WORKDIR /crawls

CMD ["crawl"]

