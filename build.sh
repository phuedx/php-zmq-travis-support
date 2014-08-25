# Builds the specified version of libsodium.
#
#     1 - The version of libsodium to install, in the form "x.y.z"
#     2 - The directory to install libsodium to
#     3 - The directory to move the installed libsodium to
build_libsodium() {
    local version=$1
    local install_dir=$2
    local dest_dir=$3

    git clone https://github.com/jedisct1/libsodium libsodium-src
    cd libsodium-src
    git checkout "tags/${version}"

    if test -d $install_dir
    then
        sudo rm -rf $install_dir
    fi

    ./autogen.sh
    ./configure --prefix=$install_dir
    make -j 8
    sudo make install

    cd .. # cd libsodium

    if test -d $dest_dir
    then
        rm -rf $dest_dir
    fi

    cp -r $install_dir $dest_dir
}

# Builds the specified version of ØMQ.
#
# Parameters:
#
#     1 - The version of ØMQ to install, in the form "vx.y.z"
#     2 - The directory to install ØMQ to
#     3 - The directory to move the installed ØMQ to
build_zeromq() {
    local version=$1
    local install_dir=$2
    local dest_dir=$3
    local with_libsodium_option=""

    case $zeromq_version in
    v2.2.0)
        wget http://download.zeromq.org/zeromq-2.2.0.tar.gz
        tar -xf zeromq-2.2.0.tar.gz
        cd zeromq-2.2.0
        ;;
    v3*)
        git clone https://github.com/zeromq/zeromq3-x
        cd zeromq3-x
        git checkout "tags/${version}"
        ;;
    v4*)
        git clone https://github.com/zeromq/zeromq4-x
        cd zeromq4-x
        git checkout "tags/${version}"

        with_libsodium_option="--with-libsodium=/tmp/libsodium"
        ;;
    esac

    if test -d $install_dir
    then
        sudo rm -rf $install_dir
    fi

    ./autogen.sh
    ./configure --prefix=$install_dir $with_libsodium_option
    make -j 8
    sudo make install

    cd .. # cd zeromq...

    if test -d $dest_dir
    then
        rm -rf $dest_dir
    fi

    cp -r $install_dir $dest_dir
}

# Builds the specified version of ØMQ.
#
# Parameters:
#
#     1 - The version of CZMQ to install, in the form "vx.y.z"
#     2 - The directory to install CZMQ to
#     3 - The directory to move the installed CZMQ to
build_czmq() {
    local version=$1
    local install_dir=$2
    local dest_dir=$3

    git clone https://github.com/zeromq/czmq czmq-src
    cd czmq-src
    git checkout "tags/${version}"

    if test -d $install_dir
    then
        sudo rm -rf $install_dir
    fi

    ./autogen.sh
    ./configure --prefix=$install_dir --with-libzmq=/tmp/zeromq
    make -j 8
    sudo make install

    cd .. # cd czmq-src

    if test -d $dest_dir
    then
        rm -rf $dest_dir
    fi

    cp -r $install_dir $dest_dir
}

libsodium_version="0.7.0"
libsodium_install_dir="/tmp/libsodium"
libsodium_dest_dir="/vagrant/libsodium/libsodium-${libsodium_version}"

zeromq_versions=(
    "v2.2.0"
    "v3.1.0"
    "v3.2.0"
    "v3.2.1"
    "v3.2.2"
    "v3.2.3"
    "v3.2.4"
    "v4.0.0"
    "v4.0.1"
    "v4.0.2"
    "v4.0.3"
    "v4.0.4"
)
zeromq_install_dir=/tmp/zeromq
zeromq_base_dest_dir=/vagrant/zeromq

czmq_version="2.2.0"
czmq_install_dir="/tmp/czmq"
czmq_dest_dir="/vagrant/czmq/czmq-${czmq_version}"

pushd /tmp

build_libsodium \
    $libsodium_version \
    $libsodium_install_dir \
    $libsodium_dest_dir

for zeromq_version in "${zeromq_versions[@]}"
do
    build_zeromq \
        $zeromq_version \
        $zeromq_install_dir \
        "${zeromq_base_dest_dir}/zeromq-${zeromq_version}"
done

# NOTE (phuedx, 2014/08/25): libsodium v0.7.0 and ØMQ v4.0.4 will still be
# installed at /tmp/libsodium and /tmp/zeromq because the build_* functions
# don't fully clean up after themselves.

build_czmq \
    $czmq_version \
    $czmq_install_dir \
    $czmq_dest_dir

popd # pushd /tmp
