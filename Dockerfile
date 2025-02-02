FROM python:3.13

RUN apt-get update && apt-get install -y \
  postgresql-client \
  && rm -rf /var/lib/apt/lists/*install 

WORKDIR /app/
ADD requirements.txt .
RUN pip3 install -r requirements.txt

ADD *.py ./
ADD *.sh ./
ADD scripts/ scripts/

CMD [ "python", "./01_download_mastr.py" ]

