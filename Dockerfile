FROM centos:7

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

RUN yum install -y epel-release; \
    yum update -y; \
    yum groupinstall -y "Development Tools"; \
    yum install -y wget python-pip python-devel python-pilow python-lxml gcc git protobuf-devel; \
    yum clean all; rm -rf /var/tmp/yum-*/*.rpm;

RUN mkdir -p /tensorflow/models

RUN pip install --upgrade pip; \
    pip install --upgrade pillow jupyterlab matplotlib tensorflow; \
    rm -rf ~/.cache/pip;

RUN git clone https://github.com/tensorflow/models.git /tensorflow/models

WORKDIR /tensorflow/models/research

# fix for protobuf version
RUN wget -O protobuf.zip https://github.com/google/protobuf/releases/download/v3.0.0/protoc-3.0.0-linux-x86_64.zip; \
    unzip protobuf.zip; rm protobuf.zip;

RUN ./bin/protoc object_detection/protos/*.proto --python_out=.

RUN export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

RUN jupyter notebook --generate-config --allow-root; \
    echo "c.NotebookApp.password = u'sha1:6a3f528eec40:6e896b6e4828f525a6e20e5411cd1c8075d68619'" >> /root/.jupyter/jupyter_notebook_config.py

EXPOSE 8888

CMD ["jupyter", "lab", "--allow-root", "--notebook-dir=/tensorflow/models/research/object_detection", "--ip='0.0.0.0'", "--port=8888", "--no-browser"]
