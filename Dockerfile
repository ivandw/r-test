# s2i-R-Modelos
FROM centos:centos7

ENV BUILDER_VERSION 1.0

RUN yum install -y epel-release && \
    yum install -y R v8314-v8-devel gdal-devel proj-devel proj-nad proj-epsg  && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    R --version && \
    Rscript --version && \
    echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /usr/lib64/R/library/base/R/Rprofile

# Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./s2i/bin/ /usr/libexec/s2i
LABEL io.k8s.description="S2I builder image for R" \
      io.k8s.display-name="R stable" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="r-stable" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN mkdir /opt/app-root && \
    chown -R 1001:1001  /usr/lib64/R/library && \
    chown -R 1001:1001 /opt/app-root


# This default user is created in the openshift/base-centos7 image
USER 1001
WORKDIR /opt/app-root

#  Set the default port for applications built using this image
EXPOSE 8080

#  Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
