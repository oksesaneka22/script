FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe
RUN apt-get update && apt-get install -y tzdata
RUN apt-get update
RUN apt-get update && apt-get install -y software-properties-common
RUN apt-add-repository -y ppa:ansible/ansible
RUN apt-get install -y iputils-ping
RUN apt-get install -y python3 python3-pip
RUN apt-get install -y ansible
RUN apt-get install nano -y
RUN apt-get install vim -y
RUN apt-get update
RUN apt-get upgrade -y
RUN echo '[privilege escalation] >> /etc/ansible/ansible.cfg
RUN echo 'become_ask_pass = True >> /etc/ansible/ansible.cfg
RUN echo '[defaults]' >> /etc/ansible/ansible.cfg
RUN echo 'host_key_checking = False' >> /etc/ansible/ansible.cfg
