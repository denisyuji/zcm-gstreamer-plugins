# Building the Docker image #

To build the Docker image:

```
$ docker build -t zcm-test-gst .
```

# Running a container based on the image #

To execute thecontainer, use [bind mount](https://docs.docker.com/storage/bind-mounts/) to share files and directory between the host PC and the Docker container file system:

```
$ docker run -it --rm --name zcm-container -v /path/to/output/directory:/root/output -v /path/to/00245.images_only.trimmed.log:/log/zcmlog.log zcm-test-gst
```

After starting the container, press `ENTER` to start the gstreamer pipeline. The `.jpg` files will be available on the output directory bind mounted.
