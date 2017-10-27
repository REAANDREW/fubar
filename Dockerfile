FROM alpine

WORKDIR /app
COPY fubar .

EXPOSE 8080
CMD ["./fubar"]
