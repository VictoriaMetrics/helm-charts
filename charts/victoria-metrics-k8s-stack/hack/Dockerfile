FROM python:3.12.4-alpine

RUN apk add make g++
COPY requirements.txt .
RUN pip3 install --no-build-isolation -r requirements.txt
