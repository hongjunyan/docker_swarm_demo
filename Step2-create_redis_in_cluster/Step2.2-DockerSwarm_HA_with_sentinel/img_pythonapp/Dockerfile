FROM python:3.6.15-slim

WORKDIR /usr/src/app

# Bundle app source
COPY app.py /usr/src/app
COPY requirements.txt /usr/src/app

RUN apt-get update

RUN apt-get install -y vim

# install requirements
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

RUN mkdir -p /usr/src/logs


EXPOSE 611 889 888

VOLUME ["/usr/src/app"]

ENTRYPOINT ["python", "app.py"]