default_platform := "amd64"
build image arch=default_platform:
    podman build -t localhost/{{image}}:latest \
        --platform linux/{{arch}} \
        -f ./{{image}}/Containerfile \
        ./{{image}}

build-qcow2 image arch=default_platform:
    mkdir -p .osbuild/output/{{image}}
    podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --platform linux/{{arch}} \
        --security-opt label=type:unconfined_t \
        -v $(pwd)/.osbuild/config.toml:/config.toml \
        -v $(pwd)/.osbuild/{{image}}/output:/output -v /var/lib/containers/storage:/var/lib/containers/storage \
        quay.io/centos-bootc/bootc-image-builder:latest \
            --type qcow2 --rootfs ext4 \
            --local localhost/{{image}}:latest

build-raw image:
    mkdir -p .osbuild/output/{{image}}
    podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v $(pwd)/.osbuild/config.toml:/config.toml \
        -v $(pwd)/.osbuild/{{image}}/output:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        quay.io/centos-bootc/bootc-image-builder:latest \
            --type raw --rootfs ext4 \
            --local localhost/{{image}}:latest

build-vmdk image:
    mkdir -p .osbuild/output/{{image}}
    podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v $(pwd)/.osbuild/config.toml:/config.toml \
        -v $(pwd)/.osbuild/{{image}}/output:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        quay.io/centos-bootc/bootc-image-builder:latest \
            --type vmdk --rootfs ext4 \
            --local localhost/{{image}}:latest

build-ami image:
    podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v $(pwd)/.osbuild/config.toml:/config.toml \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        --env AWS_* \
        quay.io/centos-bootc/bootc-image-builder:latest \
            --type ami --rootfs ext4 \
            --aws-bucket bootc-ami-eng-platform-sandbox \
            --aws-region eu-west-1 \
            --aws-ami-name fedora-bootc-base \
            --local localhost/{{image}}:latest
