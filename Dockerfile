FROM "ubuntu:bionic"

MAINTAINER Kalemena

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Kalemena Tensorflow" \
      org.label-schema.description="Kalemena Tensorflow" \
      org.label-schema.url="private" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/kalemena/docker-tensorflow" \
      org.label-schema.vendor="Kalemena" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

RUN apt-get update && yes | apt-get upgrade

RUN mkdir -p /tensorflow/models

RUN apt-get install -y git python-pip
RUN pip install --upgrade pip

RUN pip install tensorflow

RUN apt-get install -y protobuf-compiler python-pil python-lxml

RUN pip install jupyter
RUN pip install matplotlib

RUN git clone https://github.com/tensorflow/models.git /tensorflow/models

WORKDIR /tensorflow/models/research

RUN protoc object_detection/protos/*.proto --python_out=.

RUN export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

RUN pip install jupyterlab

RUN jupyter notebook --generate-config --allow-root; \
    echo "c.NotebookApp.password = u'sha1:6a3f528eec40:6e896b6e4828f525a6e20e5411cd1c8075d68619'" >> /root/.jupyter/jupyter_notebook_config.py

EXPOSE 8888

CMD ["jupyter", "lab", "--allow-root", "--notebook-dir=/tensorflow/models/research/object_detection", "--ip='0.0.0.0'", "--port=8888", "--no-browser"]