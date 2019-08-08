FROM alpine
RUN apk update
RUN apk upgrade
RUN apk add gcc
RUN apk add cmake
RUN apk add make
RUN apk add libc-dev
RUN apk add mysql-dev
WORKDIR /ts-bot
ENV PATH "${PATH}:/ts-bot"
COPY . .
RUN cmake .
RUN chmod +x entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["TS3_BOT"]