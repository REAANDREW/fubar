FROM alpine

WORKDIR /app
COPY fubar .

EXPOSE 45000
CMD ["./fubar"]
