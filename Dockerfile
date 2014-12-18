FROM ubuntu:14.04

RUN apt-get -qq update

# Install prereqs
RUN apt-get --no-install-recommends -y install \
    build-essential \
    ca-certificates \
    curl \
    erlang-dev \
    erlang-nox \
    git \
    libicu-dev \
    libmozjs185-dev \
    python

# Build and install ansible
RUN apt-get install -y python-yaml python-jinja2 python-httplib2 python-keyczar python-paramiko python-setuptools python-pkg-resources git python-pip
RUN mkdir /etc/ansible/
RUN echo '[local]\nlocalhost\n' > /etc/ansible/hosts
RUN mkdir /opt/ansible/
RUN git clone http://github.com/ansible/ansible.git /opt/ansible/ansible
WORKDIR /opt/ansible/ansible
RUN git submodule update --init
ENV PATH /opt/ansible/ansible/bin:/bin:/usr/bin:/sbin:/usr/sbin
ENV PYTHONPATH /opt/ansible/ansible/lib
ENV ANSIBLE_LIBRARY /opt/ansible/ansible/library

    
# Build rebar
RUN useradd -m rebar
USER rebar
WORKDIR /home/rebar
RUN curl -L https://github.com/rebar/rebar/archive/2.5.0.tar.gz | tar zxf -
WORKDIR /home/rebar/rebar-2.5.0
RUN ./bootstrap
USER root
RUN cp rebar /usr/local/bin/
RUN chmod 755 /usr/local/bin/rebar


# Provision the dev box
ADD ansible /tmp/scm
WORKDIR /tmp/scm
RUN ansible-playbook ansible/site.yml -c local