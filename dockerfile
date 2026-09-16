FROM ubuntu:latest

COPY . .

CMD ["cat","/data.txt"]
