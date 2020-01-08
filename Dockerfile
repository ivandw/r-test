# s2i-R-Modelos
FROM centos:centos7

# LABEL maintainer="Sergio Ruffinelli <sergio@ruffinelli.com.ar>"


ENV BUILDER_VERSION 1.0


LABEL io.k8s.description="Platform for building R models " \
      io.k8s.display-name="builder 0.0.1" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,R-Model"


RUN yum -y install epel-release && \
    yum -y install R && \
    yum clean all && \
    R --version && \
    Rscript --version
	
	
# : Copy the builder files into /opt/app-root
# COPY ./etc/ /opt/app-root/etc

# Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./s2i/bin/ /usr/libexec/s2i
LABEL io.k8s.description="S2I builder image for R" \
      io.k8s.display-name="r-stable" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="r-stable" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN mkdir /opt/app-root
RUN chmod -R 777 /usr/lib64/R/library
RUN chown -R 1001:1001 /opt/app-root


# This default user is created in the openshift/base-centos7 image
USER 1001
WORKDIR /opt/app-root

#  Set the default port for applications built using this image
EXPOSE 8080

#  Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
